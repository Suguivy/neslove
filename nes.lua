require "bit"
local util = require "util"
local printf = util.printf

local nes = {}

local mirroring_modes = {
    "horizontal mirroring",
    "vertical mirroring",
    "four-screen mirroring"
}

-- Currently only iNES file format
function nes.load_cart(cart)
    cart = assert(io.open(cart, "rb"))
    if cart:read(3) == "NES" and cart:read(1):byte(1) == 0x1A then
        local pgr_banks = cart:read(1):byte(1)
        local chr_banks = cart:read(1):byte(1)
        local ctrl_byte1 = cart:read(1):byte(1)
        local ctrl_byte2 = cart:read(1):byte(1)
        local ram_banks = cart:read(1):byte(1); if ram_banks == 0 then ram_banks = 1 end

        local has_batt_ram = bit.band(0x02, ctrl_byte1) ~= 0
        local has_trainer = bit.band(0x04, ctrl_byte1) ~= 0
        local mirroring_mode = bit.band(0x08, ctrl_byte1) == 0
            and bit.band(0x01, ctrl_byte1) or 2 -- (0x08 & ctrl_byte1 == 0) ? (0x01 & ctrl_byte1) : 2
        local mapper = bit.bor(bit.band(ctrl_byte2, 0xF0), bit.rshift(ctrl_byte1, 4)) -- (ctrl_byte2 & 0xF0) || (ctrl_byte1 >> 4)

        printf("Cartridge info:")
        printf("Number of 16KiB PGR-ROM banks: %d", pgr_banks)
        printf("Number of 8KiB CHR-ROM/VROM banks: %d", chr_banks)
        printf("Number of 8KiB RAM banks: %d", ram_banks)
        if has_batt_ram then print "Has a battery-backed RAM" end
        if has_trainer then print "Has 512-byte trainer at $7000-$71FF" end
        printf("The game uses %s", mirroring_modes[mirroring_mode + 1])
        printf("Mapper number: %d", mapper)
        cart:read(7) -- Unused bytes for the iNES format
    else
        print "Error, the file is not a valid iNES rom"
    end
end

return nes