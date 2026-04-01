ZVox = ZVox or {}

CHUNK_TRANSMIT_WAIT = .5 -- lower to .1 or .15 on dedi
--CHUNK_TRANSMIT_MAX_PER_MESSAGE = 5 -- 8 * 8 * 8 * 8 * 5 * 2 < 64kb
CHUNK_TRANSMIT_MAX_PER_MESSAGE = 8 -- turbo mode for dev

ZVOX_CHUNK_TRANSMIT_MAX_BUFFER_SIZE = 1024 * 32 -- 32kb per message


SKIN_TRANSMIT_WAIT = .1