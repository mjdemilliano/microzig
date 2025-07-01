pub fn delay(ticks: u32) void {
    for (0..ticks) |_| {
        asm volatile ("nop");
    }
}
