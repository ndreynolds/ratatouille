TERMBOX_PATH = c_src/termbox
TERMBOX_BUILD = $(TERMBOX_PATH)/build/src

ERLANG_INCLUDE_PATH = $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)

CFLAGS += -I$(ERLANG_INCLUDE_PATH) -I$(TERMBOX_PATH)/src -fPIC
LDFLAGS += -shared

SOURCES = c_src/termbox_bindings.c $(TERMBOX_BUILD)/libtermbox.a

ifeq ($(shell uname),Darwin)
	LDFLAGS += -dynamiclib -undefined dynamic_lookup
endif

all: priv/termbox_bindings.so

$(TERMBOX_BUILD)/libtermbox.%:
	cd $(TERMBOX_PATH) && CFLAGS=-fPIC ./waf configure --prefix=. && ./waf

priv/termbox_bindings.so: $(SOURCES)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(SOURCES)

clean:
	rm -rf $(TERMBOX_BUILD) priv/termbox_bindings.so

.PHONY: all clean
