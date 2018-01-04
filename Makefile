ERLANG_INCLUDE_PATH = $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)

CFLAGS += -I$(ERLANG_INCLUDE_PATH)

ifneq ($(OS),Windows_NT)
	CFLAGS += -fPIC
	LDFLAGS += -shared -L/usr/local/lib -ltermbox

	ifeq ($(shell uname),Darwin)
		LDFLAGS += -dynamiclib -undefined dynamic_lookup
	endif
endif

all: priv/termbox_bindings.so

priv/termbox_bindings.so: c_src/termbox_bindings.c
	cc $(CFLAGS) $(LDFLAGS) -o $@ c_src/termbox_bindings.c

clean:
	rm priv/termbox_bindings.so

.PHONY: all clean
