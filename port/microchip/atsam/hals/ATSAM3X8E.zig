const microzig = @import("microzig");
const peripherals = microzig.chip.peripherals;
pub const time = @import("time.zig");

pub fn system_init() void {
    // Disable watchdog.
    peripherals.WDT.MR.modify(.{
        .WDDIS = 1,
    });

    // For each flash bank, set flash wait state to wait for 5 cycles.
    peripherals.EFC0.FMR.modify(.{ .FWS = 4 });
    peripherals.EFC1.FMR.modify(.{ .FWS = 4 });

    // Initialize main oscillator.
    peripherals.PMC.CKGR_MOR.write(.{
        // .KEY = 55, // Set password (see SVD file for source of value)
        .KEY = .PASSWD,
        .MOSCRCEN = 1, // Main On-Chip RC Oscillator enable at 4 MHz
        .MOSCXTEN = 1, // Main Crystal Oscillator enable at 84 MHz
        .MOSCSEL = 1,
        .MOSCRCF = .@"4_MHz",
        .MOSCXTST = 8,
        .MOSCXTBY = 0,
        .CFDEN = 1,
    });

    // Wait until main oscillator is high.
    while (peripherals.PMC.PMC_SR.read().MOSCXTS != 1) {}

    // Initialize PLLA.
    peripherals.PMC.CKGR_PLLAR.write(.{
        .ONE = 1,
        .MULA = 0xD,
        .PLLACOUNT = 0x3F,
        .DIVA = 0x1,
    });

    // Wait until PLLA lock status is high.
    while (peripherals.PMC.PMC_SR.read().LOCKA != 1) {}

    // Switch to main clock.
    peripherals.PMC.PMC_MCKR.write(.{
        .PRES = .CLK_2,
        .CSS = .MAIN_CLK,
        .PLLADIV2 = 0,
        .UPLLDIV2 = 0,
    });

    // Wait until master clock is ready.
    while (peripherals.PMC.PMC_SR.read().MCKRDY != 1) {}

    // Switch to PLLA.
    peripherals.PMC.PMC_MCKR.write(.{
        .PRES = .CLK_2,
        .CSS = .PLLA_CLK,
        .PLLADIV2 = 0,
        .UPLLDIV2 = 0,
    });
}
