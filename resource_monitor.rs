// Made By DrKel
// Please Credit DrKel if reusing in your own scripts. (Or VisAwesme or Vaughn R)
// Reminder: This is unfinished and may not work.
use sysinfo::{System, RefreshKind, CpuRefreshKind};
use notify_rust::Notification;
use std::{thread, time::Duration};

fn notify(title: &str, message: &str) {
    Notification::new()
        .summary(title)
        .body(message)
        .timeout(5000) // 5 seconds
        .show()
        .unwrap();
}

fn main() {
    let mut sys = System::new_with_specifics(RefreshKind::everything().with_cpu(CpuRefreshKind::everything()));

    // Notify on startup
    notify("System Monitor", "Monitoring system resources...");

    loop {
        sys.refresh_cpu_all(); // Instead of refresh_cpu()

        let ram_usage = sys.used_memory() as f64 / sys.total_memory() as f64 * 100.0;
        let swap_usage = sys.used_swap() as f64 / sys.total_swap() as f64 * 100.0;
        let cpu_usage = sys.global_cpu_usage();

        if ram_usage >= 80.0 {
            notify("⚠ High RAM Usage!", &format!("RAM at {:.2}%", ram_usage));
        }

        if swap_usage >= 30.0 {
            notify("⚠ High Swap Usage!", &format!("Swap at {:.2}%", swap_usage));
        }

        if cpu_usage >= 85.0 {
            notify("⚠ High CPU Usage!", &format!("CPU at {:.2}%", cpu_usage));
        }

        thread::sleep(Duration::from_secs(10)); // Check every 10 seconds
    }
}
