#!/usr/bin/env python3
"""Beginner-friendly Tkinter GUI for the RISC-V CPU Core Makefile flow."""

from __future__ import annotations

import platform
import queue
import subprocess
import threading
from pathlib import Path
import tkinter as tk
from tkinter import filedialog, messagebox, ttk
from tkinter.scrolledtext import ScrolledText
from typing import List, Optional, TextIO, Tuple, Union


PROJECT_ROOT = Path(__file__).resolve().parents[1]
PROGRAM_DIR = PROJECT_ROOT / "tests" / "programs"
WAVE_DIR = PROJECT_ROOT / "sim" / "waves"
CORE_WAVE = WAVE_DIR / "riscv_core.vcd"
PIPELINE_WAVE = WAVE_DIR / "riscv_pipelined_core.vcd"


COMMANDS = [
    ("Run All Tests", ["make", "test-all"]),
    ("Run Single-Cycle Core Test", ["make", "test-core"]),
    ("Run Pipelined Core Test", ["make", "test-pipeline"]),
    ("Run Pipeline Hazard Tests", ["make", "test-pipeline-hazards"]),
    ("Run Pipeline Control Flow Tests", ["make", "test-pipeline-control-flow"]),
    ("Run Verilator Lint", ["make", "verilator-lint"]),
    ("Run cocotb Tests", ["make", "cocotb-test"]),
    ("Verify .mem Files", ["make", "verify-mem"]),
    ("Generate Single-Cycle Waveform", ["make", "wave-core"]),
    ("Generate Pipeline Waveform", ["make", "wave-pipeline"]),
    ("Run Formal Checks", ["make", "formal-all"]),
    ("Clean Build Outputs", ["make", "clean"]),
]


class RiscVGui(tk.Tk):
    """Main application window."""

    def __init__(self) -> None:
        super().__init__()
        self.title("RISC-V CPU Core Simulator")
        self.geometry("980x720")
        self.minsize(760, 560)

        self.output_queue: "queue.Queue[Tuple[str, Union[str, int, List[str]]]]" = queue.Queue()
        self.current_process: Optional[subprocess.Popen] = None
        self.command_running = False
        self.command_buttons: List[ttk.Button] = []
        self.program_var = tk.StringVar()
        self.status_var = tk.StringVar(value="Ready")

        self._build_layout()
        self._load_programs()
        self.after(100, self._process_output_queue)

    def _build_layout(self) -> None:
        """Create the controls, output box, and status bar."""
        self.columnconfigure(0, weight=1)
        self.rowconfigure(3, weight=1)

        header = ttk.Frame(self, padding=(12, 12, 12, 6))
        header.grid(row=0, column=0, sticky="ew")
        header.columnconfigure(0, weight=1)

        title = ttk.Label(header, text="RISC-V CPU Core Simulator", font=("TkDefaultFont", 16, "bold"))
        title.grid(row=0, column=0, sticky="w")

        subtitle = ttk.Label(
            header,
            text="Run existing Makefile simulation, verification, waveform, and cleanup targets.",
        )
        subtitle.grid(row=1, column=0, sticky="w", pady=(4, 0))

        command_frame = ttk.LabelFrame(self, text="Makefile Commands", padding=10)
        command_frame.grid(row=1, column=0, sticky="ew", padx=12, pady=6)
        for index, (label, command) in enumerate(COMMANDS):
            button = ttk.Button(command_frame, text=label, command=lambda cmd=command: self.run_command(cmd))
            button.grid(row=index // 3, column=index % 3, sticky="ew", padx=4, pady=4)
            command_frame.columnconfigure(index % 3, weight=1)
            self.command_buttons.append(button)

        program_frame = ttk.LabelFrame(self, text="Program Selector", padding=10)
        program_frame.grid(row=2, column=0, sticky="ew", padx=12, pady=6)
        program_frame.columnconfigure(1, weight=1)

        ttk.Label(program_frame, text=".mem program:").grid(row=0, column=0, sticky="w", padx=(0, 8))
        self.program_combo = ttk.Combobox(program_frame, textvariable=self.program_var, state="readonly")
        self.program_combo.grid(row=0, column=1, sticky="ew", padx=4)

        browse_button = ttk.Button(program_frame, text="Choose File...", command=self.choose_program_file)
        browse_button.grid(row=0, column=2, sticky="ew", padx=4)

        run_selected = ttk.Button(program_frame, text="Run Selected Program", command=self.run_selected_program)
        run_selected.grid(row=0, column=3, sticky="ew", padx=4)
        self.command_buttons.append(run_selected)

        wave_frame = ttk.Frame(program_frame)
        wave_frame.grid(row=1, column=0, columnspan=4, sticky="ew", pady=(10, 0))
        wave_frame.columnconfigure(0, weight=1)
        ttk.Label(wave_frame, text=f"Single-cycle waveform: {CORE_WAVE.relative_to(PROJECT_ROOT)}").grid(
            row=0, column=0, sticky="w"
        )
        ttk.Label(wave_frame, text=f"Pipeline waveform: {PIPELINE_WAVE.relative_to(PROJECT_ROOT)}").grid(
            row=1, column=0, sticky="w", pady=(2, 0)
        )
        open_wave_button = ttk.Button(wave_frame, text="Open Waveform Folder", command=self.open_wave_folder)
        open_wave_button.grid(row=0, column=1, rowspan=2, sticky="e", padx=(8, 0))
        self.command_buttons.append(open_wave_button)

        output_frame = ttk.LabelFrame(self, text="Command Output", padding=10)
        output_frame.grid(row=3, column=0, sticky="nsew", padx=12, pady=6)
        output_frame.rowconfigure(0, weight=1)
        output_frame.columnconfigure(0, weight=1)

        self.output_text = ScrolledText(output_frame, wrap=tk.WORD, height=20)
        self.output_text.grid(row=0, column=0, sticky="nsew")
        self.output_text.configure(state=tk.DISABLED)

        status = ttk.Label(self, textvariable=self.status_var, relief=tk.SUNKEN, anchor="w", padding=(8, 4))
        status.grid(row=4, column=0, sticky="ew")

    def _load_programs(self) -> None:
        """Populate the program dropdown from tests/programs/*.mem."""
        programs = sorted(PROGRAM_DIR.glob("*.mem"))
        values = [str(path.relative_to(PROJECT_ROOT)) for path in programs]
        self.program_combo["values"] = values
        if values:
            self.program_var.set(values[0])
        else:
            self.program_var.set("No .mem files found")

    def choose_program_file(self) -> None:
        """Allow a user to select another .mem file manually."""
        path = filedialog.askopenfilename(
            title="Choose .mem program",
            initialdir=PROGRAM_DIR,
            filetypes=[("Memory files", "*.mem"), ("All files", "*.*")],
        )
        if not path:
            return

        selected = Path(path)
        try:
            display_path = str(selected.resolve().relative_to(PROJECT_ROOT))
        except ValueError:
            display_path = str(selected)

        values = list(self.program_combo["values"])
        if display_path not in values:
            values.append(display_path)
            self.program_combo["values"] = values
        self.program_var.set(display_path)

    def run_selected_program(self) -> None:
        """Run the selected .mem file through the Makefile-supported PROGRAM variable."""
        program = self.program_var.get()
        if not program or program == "No .mem files found":
            messagebox.showinfo("No program selected", "Choose a .mem file before running a program.")
            return
        self.run_command(["make", "test-core", f"PROGRAM={program}"])

    def open_wave_folder(self) -> None:
        """Open sim/waves with the platform's normal file browser."""
        WAVE_DIR.mkdir(parents=True, exist_ok=True)
        system = platform.system()
        if system == "Darwin":
            command = ["open", str(WAVE_DIR)]
        elif system == "Windows":
            command = ["explorer", str(WAVE_DIR)]
        else:
            command = ["xdg-open", str(WAVE_DIR)]
        self.run_command(command)

    def run_command(self, command: List[str]) -> None:
        """Start a command in a worker thread so Tkinter remains responsive."""
        if self.command_running:
            messagebox.showinfo("Command already running", "Wait for the current command to finish first.")
            return

        self.command_running = True
        self._set_buttons_enabled(False)
        self.status_var.set("Running command...")
        self._append_output(f"\n$ {' '.join(command)}\n")

        worker = threading.Thread(target=self._run_subprocess, args=(command,), daemon=True)
        worker.start()

    def _run_subprocess(self, command: List[str]) -> None:
        """Run subprocess output line-by-line and pass it back to the Tkinter thread."""
        try:
            process = subprocess.Popen(
                command,
                cwd=PROJECT_ROOT,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                bufsize=1,
            )
            self.current_process = process

            assert process.stdout is not None
            assert process.stderr is not None

            stdout_thread = threading.Thread(
                target=self._read_stream,
                args=(process.stdout, ""),
                daemon=True,
            )
            stderr_thread = threading.Thread(
                target=self._read_stream,
                args=(process.stderr, "stderr: "),
                daemon=True,
            )
            stdout_thread.start()
            stderr_thread.start()

            return_code = process.wait()
            stdout_thread.join()
            stderr_thread.join()
            self.output_queue.put(("done", return_code))
        except FileNotFoundError as exc:
            self.output_queue.put(("output", f"Command failed to start: {exc}\n"))
            self.output_queue.put(("done", 127))
        except OSError as exc:
            self.output_queue.put(("output", f"Command error: {exc}\n"))
            self.output_queue.put(("done", 1))

    def _read_stream(self, stream: TextIO, prefix: str) -> None:
        """Forward stdout or stderr lines from a subprocess to the GUI queue."""
        for line in stream:
            self.output_queue.put(("output", f"{prefix}{line}"))

    def _process_output_queue(self) -> None:
        """Apply worker-thread messages safely from the Tkinter event loop."""
        while True:
            try:
                event, payload = self.output_queue.get_nowait()
            except queue.Empty:
                break

            if event == "output":
                self._append_output(str(payload))
            elif event == "done":
                return_code = int(payload)
                if return_code == 0:
                    self._append_output("Command passed\n")
                    self.status_var.set("Command passed")
                else:
                    self._append_output(f"Command failed with exit code {return_code}\n")
                    self.status_var.set("Command failed")
                self.current_process = None
                self.command_running = False
                self._set_buttons_enabled(True)

        self.after(100, self._process_output_queue)

    def _append_output(self, text: str) -> None:
        """Append text to the output area and scroll to the newest line."""
        self.output_text.configure(state=tk.NORMAL)
        self.output_text.insert(tk.END, text)
        self.output_text.see(tk.END)
        self.output_text.configure(state=tk.DISABLED)

    def _set_buttons_enabled(self, enabled: bool) -> None:
        state = tk.NORMAL if enabled else tk.DISABLED
        for button in self.command_buttons:
            button.configure(state=state)


if __name__ == "__main__":
    app = RiscVGui()
    app.mainloop()
