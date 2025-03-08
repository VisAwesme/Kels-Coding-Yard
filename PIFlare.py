#PiFlare

import sys
import time
import psutil
from mpmath import mp, factorial, sqrt
from PyQt6.QtCore import QTimer, QThread, pyqtSignal
from PyQt6.QtWidgets import (
    QApplication, QWidget, QVBoxLayout, QHBoxLayout, QLabel, QPushButton, 
    QTextEdit, QProgressBar, QLineEdit, QDialog, QFormLayout, QLineEdit as QLE, 
    QComboBox, QDialogButtonBox
)

# Settings Dialog
class SettingsDialog(QDialog):
    def __init__(self, parent=None, current_settings=None):
        super().__init__(parent)
        self.setWindowTitle("Settings")
        self.current_settings = current_settings or {}
        self.setup_ui()
        
    def setup_ui(self):
        layout = QFormLayout(self)
        
        # Recent Digit Color
        self.recent_digit_color_edit = QLE(self)
        self.recent_digit_color_edit.setPlaceholderText("e.g., #FF0000")
        self.recent_digit_color_edit.setText(self.current_settings.get("recent_digit_color", "#FF0000"))
        layout.addRow("Recent Digit Color:", self.recent_digit_color_edit)
        
        # Normal Number Color
        self.normal_number_color_edit = QLE(self)
        self.normal_number_color_edit.setPlaceholderText("e.g., #000000")
        self.normal_number_color_edit.setText(self.current_settings.get("normal_number_color", "#000000"))
        layout.addRow("Normal Number Color:", self.normal_number_color_edit)
        
        # Terminal Type
        self.terminal_combo = QComboBox(self)
        self.terminal_combo.addItems(["Kitty", "Konsole", "Fish", "Other"])
        current_terminal = self.current_settings.get("terminal", "Kitty")
        index = self.terminal_combo.findText(current_terminal)
        if index >= 0:
            self.terminal_combo.setCurrentIndex(index)
        layout.addRow("Terminal Type:", self.terminal_combo)
        
        # OK and Cancel buttons
        self.button_box = QDialogButtonBox(
            QDialogButtonBox.StandardButton.Ok | QDialogButtonBox.StandardButton.Cancel, self
        )
        self.button_box.accepted.connect(self.accept)
        self.button_box.rejected.connect(self.reject)
        layout.addWidget(self.button_box)
        
    def get_settings(self):
        return {
            "recent_digit_color": self.recent_digit_color_edit.text(),
            "normal_number_color": self.normal_number_color_edit.text(),
            "terminal": self.terminal_combo.currentText(),
        }

# Calculation Thread remains mostly the same.
class PiCalculationThread(QThread):
    update_signal = pyqtSignal(str)
    progress_signal = pyqtSignal(int)

    def __init__(self, digits, mode, parent=None):
        super().__init__(parent)
        self.digits = digits
        self.mode = mode
        self.running = True

    def run(self):
        mp.dps = self.digits
        if self.mode == "one_by_one":
            generator = self.pi_digit_by_digit_generator(self.digits)
        else:
            generator = self.chudnovsky_generator(self.digits)
        previous_pi = ""
        while self.running:
            try:
                pi_value = next(generator)
                if pi_value == previous_pi:
                    break
                previous_pi = pi_value
                self.update_signal.emit(pi_value)
                progress = int((len(pi_value) / self.digits) * 100)
                self.progress_signal.emit(progress)
                time.sleep(0.1 if self.mode == "one_by_one" else 0)
            except StopIteration:
                break

    def stop(self):
        self.running = False
        self.quit()
        self.wait()

    def chudnovsky_generator(self, digits):
        C = 426880 * sqrt(10005)
        sum_val = mp.mpf(0)
        k = 0
        while True:
            term = ((-1) ** k * factorial(6 * k) * (545140134 * k + 13591409)) / \
                   (factorial(3 * k) * (factorial(k) ** 3) * (640320 ** (3 * k)))
            sum_val += term
            yield str(C / sum_val)
            k += 1

    def pi_digit_by_digit_generator(self, digits):
        pi_str = str(mp.pi)
        for i in range(2, len(pi_str)):
            if not self.running:
                break
            yield pi_str[:i]
            time.sleep(0.1)

# Main GUI
class PiCalculatorGUI(QWidget):
    def __init__(self):
        super().__init__()

        self.setWindowTitle("Pi Calculator & System Monitor")
        self.setGeometry(100, 100, 650, 450)
        self.running = False
        self.start_time = 0
        self.calc_thread = None
        self.terminal_mode = False  # Classic mode (kinda)
        
        # Terminal settings thing
        self.settings = {
            "recent_digit_color": "#FF0000",
            "normal_number_color": "#000000",
            "terminal": "Kitty"
        }

        main_layout = QVBoxLayout(self)

        # Menu layout
        menu_layout = QHBoxLayout()
        self.start_button_one = QPushButton("Start (One by One)", self)
        self.start_button_one.clicked.connect(lambda: self.start_calculation("one_by_one"))
        menu_layout.addWidget(self.start_button_one)

        self.start_button_fast = QPushButton("Start (Fast Mode)", self)
        self.start_button_fast.clicked.connect(lambda: self.start_calculation("fast"))
        menu_layout.addWidget(self.start_button_fast)

        self.stop_button = QPushButton("Stop", self)
        self.stop_button.clicked.connect(self.stop_calculation)
        menu_layout.addWidget(self.stop_button)

        self.clear_button = QPushButton("Clear", self)
        self.clear_button.clicked.connect(self.clear_output)
        menu_layout.addWidget(self.clear_button)

        self.terminal_button = QPushButton("Switch to Terminal Mode", self)
        self.terminal_button.clicked.connect(self.toggle_terminal_mode)
        menu_layout.addWidget(self.terminal_button)
        
        # New super cool settings button I made in 30 minutes!
        self.settings_button = QPushButton("Settings", self)
        self.settings_button.clicked.connect(self.open_settings)
        menu_layout.addWidget(self.settings_button)

        main_layout.addLayout(menu_layout)

        # CPU, RAM, Time monitor things (GUI)
        monitor_layout = QHBoxLayout()
        self.cpu_label = QLabel("CPU: 0%", self)
        monitor_layout.addWidget(self.cpu_label)
        self.ram_label = QLabel("RAM: 0%", self)
        monitor_layout.addWidget(self.ram_label)
        self.time_label = QLabel("Time: 0s", self)
        monitor_layout.addWidget(self.time_label)
        main_layout.addLayout(monitor_layout)

        # Pi display area (you know, the whole purpose of this)
        self.pi_display = QTextEdit(self)
        self.pi_display.setFontFamily("Courier")
        self.pi_display.setFontPointSize(12)
        self.pi_display.setReadOnly(True)
        main_layout.addWidget(self.pi_display)

        # Line counter thing
        self.line_counter = QLabel("Lines: 0", self)
        self.line_counter.setStyleSheet("color: purple;")
        main_layout.addWidget(self.line_counter)

        # Progress bar
        self.progress_bar = QProgressBar(self)
        self.progress_bar.setRange(0, 100)
        main_layout.addWidget(self.progress_bar)

        # Text bar (Entry field)
        self.digit_entry = QLineEdit(self)
        self.digit_entry.setText("100")
        main_layout.addWidget(self.digit_entry)

        self.update_monitor()  # Start live system monitoring

    def update_monitor(self):
        if self.running:
            cpu_usage = psutil.cpu_percent(interval=0.5)
            ram_usage = psutil.virtual_memory().percent
            elapsed_time = time.time() - self.start_time
            self.cpu_label.setText(f"CPU: {cpu_usage}%")
            self.ram_label.setText(f"RAM: {ram_usage}%")
            self.time_label.setText(f"Time: {elapsed_time:.2f}s")
        QTimer.singleShot(500, self.update_monitor)

    def update_line_count(self):
        num_lines = len(self.pi_display.toPlainText().split("\n"))
        self.line_counter.setText(f"Lines: {num_lines}")

    def clear_output(self):
        self.pi_display.clear()
        self.update_line_count()

    def start_calculation(self, mode):
        if self.running:
            return  # Prevent multiple calculations at once
        self.running = True
        self.clear_output()
        self.start_time = time.time()  # Timer starts here!
        digits = int(self.digit_entry.text())

        self.calc_thread = PiCalculationThread(digits, mode)
        self.calc_thread.update_signal.connect(self.update_pi_display)
        self.calc_thread.progress_signal.connect(self.progress_bar.setValue)
        self.calc_thread.finished.connect(self.on_calculation_finished)
        self.calc_thread.start()

    def stop_calculation(self):
        self.running = False
        if self.calc_thread:
            self.calc_thread.stop()
            self.calc_thread = None

    def on_calculation_finished(self):
        self.running = False
        elapsed_time = time.time() - self.start_time
        self.time_label.setText(f"Time: {elapsed_time:.2f}s (Finished)")

    def update_pi_display(self, pi_value):
        if self.terminal_mode:
            print(pi_value)
        else:
            # idk
            color = self.settings.get("recent_digit_color", "#FF0000")
            formatted_text = f'<span style="color: {color};">{pi_value}</span>'
            self.pi_display.append(formatted_text)
            self.update_line_count()

    def toggle_terminal_mode(self):
        self.terminal_mode = not self.terminal_mode
        if self.terminal_mode:
            self.pi_display.hide()
            self.line_counter.hide()
            self.progress_bar.hide()
            self.digit_entry.hide()
            self.terminal_button.setText("Switch to GUI Mode")
            print("Terminal Mode Activated. Pi output will now appear in the console.")
        else:
            self.pi_display.show()
            self.line_counter.show()
            self.progress_bar.show()
            self.digit_entry.show()
            self.terminal_button.setText("Switch to Terminal Mode")
            print("GUI Mode Activated. Pi output will now appear in the window.")

    def open_settings(self):
        dialog = SettingsDialog(self, self.settings)
        if dialog.exec() == QDialog.DialogCode.Accepted:
            self.settings = dialog.get_settings()
            print("Settings updated:", self.settings)

if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = PiCalculatorGUI()
    window.show()
    sys.exit(app.exec())
