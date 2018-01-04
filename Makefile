ERLANG_INCLUDE_PATH = $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)

CFLAGS += -I$(ERLANG_INCLUDE_PATH)

TERMBOX_SRC = c_src/termbox
TERMBOX_BUILD = $(TERMBOX_SRC)/build/src

DEST_DIR = ./priv

ifneq ($(OS),Windows_NT)
	CFLAGS += -fPIC
	LDFLAGS += -shared -L$(DEST_DIR) -Wl,-rpath=$(DEST_DIR) -ltermbox

	ifeq ($(shell uname),Darwin)
		LDFLAGS += -dynamiclib -undefined dynamic_lookup
	endif
endif

all: $(DEST_DIR)/termbox_bindings.so

$(TERMBOX_BUILD)/libtermbox.%:
	cd $(TERMBOX_SRC) && ./waf configure --prefix=. && ./waf

$(DEST_DIR)/libtermbox.%: $(TERMBOX_BUILD)/libtermbox.%
	cp $< $@

$(DEST_DIR)/termbox_bindings.so: $(DEST_DIR)/libtermbox.so.1 $(DEST_DIR)/libtermbox.so c_src/termbox_bindings.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ c_src/termbox_bindings.c

clean:
	rm -rf $(TERMBOX_BUILD) $(DEST_DIR)/libtermbox.so* $(DEST_DIR)/termbox_bindings.so

.PHONY: all clean
