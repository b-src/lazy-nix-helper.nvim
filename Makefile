# TODO: look at adding --noplugin when setup handles installing its own deps
test:
	nvim --headless -u tests/init.lua -c "PlenaryBustedDirectory tests { minimal_init = 'tests/init.lua' }"
