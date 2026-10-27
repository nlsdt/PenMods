# Host test harness (dev only). The device build stays on xmake.
#
#   make -j$(nproc)          build every test
#   make -j$(nproc) run      build and run
#   make TESTS="test_protocol test_context" run
#   make SANITIZE=1 run      ASan + UBSan (separate object dir)
#
# Objects and the SQLiteCpp archive live under build/tests/{opt,san}, so an
# unchanged module is never rebuilt again. SQLiteCpp is compiled once, not once
# per session test.

CXX ?= g++
OUT ?= ../build/tests
SANITIZE ?= 0
SQLITECPP_DIR ?= ../.tmp/SQLiteCpp

QT_CFLAGS := $(shell pkg-config --cflags Qt5Core)
QT_LIBS   := $(shell pkg-config --libs Qt5Core)

ifeq ($(SANITIZE),1)
SAN_FLAGS := -fsanitize=address,undefined -fno-omit-frame-pointer -g
BUILD     := $(OUT)/san
else
SAN_FLAGS :=
BUILD     := $(OUT)/opt
endif

CXXFLAGS := $(SAN_FLAGS) -std=c++23 -fPIC -O2 -Wall -Wextra -I../src \
            -I$(SQLITECPP_DIR)/include $(QT_CFLAGS)
LDLIBS   := -lsqlite3 $(QT_LIBS)

SRC := ../src/chatbot

# Shared modules: compiled once into $(OBJ)/… and linked into the tests that need them.
MODULES := \
	core/RequestLog.cpp \
	core/MessageJson.cpp \
	context/HistoryTrimmer.cpp \
	context/ContextAssembler.cpp \
	protocol/ProtocolCommon.cpp \
	protocol/ProtocolAdapter.cpp \
	protocol/ChatCompletionsAdapter.cpp \
	protocol/ResponsesAdapter.cpp \
	model/ModelRegistry.cpp \
	model/PromptStore.cpp \
	tools/ToolRuntime.cpp \
	tools/ShellTool.cpp \
	tools/WebSearchTool.cpp \
	engine/ChatEngine.cpp \
	session/SessionStore.cpp \
	session/SessionRepository.cpp \
	session/SessionManager.cpp

OBJ := $(BUILD)/obj
MODULE_OBJS := $(patsubst %.cpp,$(OBJ)/%.o,$(MODULES))

SQLITECPP_SRC  := $(shell find $(SQLITECPP_DIR)/src -name '*.cpp' 2>/dev/null)
SQLITECPP_OBJS := $(patsubst $(SQLITECPP_DIR)/src/%.cpp,$(OBJ)/sqlitecpp/%.o,$(SQLITECPP_SRC))
SQLITECPP_LIB  := $(BUILD)/libsqlitecpp.a

TESTS ?= test_request_log test_history_trim test_message_json test_request_sequence \
         test_protocol test_context test_models test_tools test_shell_tool \
         test_search_tool test_chat_engine test_session_store \
         test_session_repository test_session_manager

BINS := $(addprefix $(BUILD)/,$(TESTS))

test_request_log_OBJS        := $(OBJ)/core/RequestLog.o
test_history_trim_OBJS       := $(OBJ)/context/HistoryTrimmer.o
test_message_json_OBJS       := $(OBJ)/core/MessageJson.o
test_request_sequence_OBJS   := $(OBJ)/core/MessageJson.o $(OBJ)/context/HistoryTrimmer.o
test_protocol_OBJS           := $(OBJ)/core/MessageJson.o $(OBJ)/protocol/ProtocolCommon.o \
                                $(OBJ)/protocol/ProtocolAdapter.o $(OBJ)/protocol/ChatCompletionsAdapter.o \
                                $(OBJ)/protocol/ResponsesAdapter.o
test_context_OBJS            := $(OBJ)/context/ContextAssembler.o $(OBJ)/context/HistoryTrimmer.o
test_models_OBJS             := $(OBJ)/model/ModelRegistry.o $(OBJ)/model/PromptStore.o
test_tools_OBJS              := $(OBJ)/tools/ToolRuntime.o $(OBJ)/context/ContextAssembler.o \
                                $(OBJ)/context/HistoryTrimmer.o
test_shell_tool_OBJS         := $(OBJ)/tools/ShellTool.o $(OBJ)/tools/ToolRuntime.o \
                                $(OBJ)/context/ContextAssembler.o $(OBJ)/context/HistoryTrimmer.o
test_search_tool_OBJS        := $(OBJ)/tools/WebSearchTool.o
test_chat_engine_OBJS        := $(OBJ)/engine/ChatEngine.o $(OBJ)/core/MessageJson.o \
                                $(OBJ)/protocol/ProtocolCommon.o $(OBJ)/protocol/ProtocolAdapter.o \
                                $(OBJ)/protocol/ChatCompletionsAdapter.o $(OBJ)/protocol/ResponsesAdapter.o
test_session_store_OBJS      := $(OBJ)/session/SessionStore.o $(SQLITECPP_LIB)
test_session_repository_OBJS := $(OBJ)/session/SessionStore.o $(OBJ)/session/SessionRepository.o $(SQLITECPP_LIB)
test_session_manager_OBJS    := $(OBJ)/session/SessionStore.o $(OBJ)/session/SessionRepository.o \
                                $(OBJ)/session/SessionManager.o $(SQLITECPP_LIB)

.PHONY: all run clean

# Keep object files between runs; implicit-rule intermediates are deleted by default.
.PRECIOUS: $(OBJ)/%.o $(OBJ)/tests/%.o $(OBJ)/sqlitecpp/%.o

all: $(BINS)

.SECONDEXPANSION:
$(BUILD)/%: $(OBJ)/tests/%.o $$($$*_OBJS)
	@mkdir -p $(dir $@)
	@$(CXX) $(SAN_FLAGS) -o $@ $^ $(LDLIBS)

$(OBJ)/%.o: ../src/chatbot/%.cpp
	@mkdir -p $(dir $@)
	@$(CXX) $(CXXFLAGS) -MMD -MP -c $< -o $@

$(OBJ)/tests/%.o: %.cpp
	@mkdir -p $(dir $@)
	@$(CXX) $(CXXFLAGS) -MMD -MP -c $< -o $@

$(OBJ)/sqlitecpp/%.o: $(SQLITECPP_DIR)/src/%.cpp
	@mkdir -p $(dir $@)
	@$(CXX) $(CXXFLAGS) -MMD -MP -c $< -o $@

$(SQLITECPP_LIB): $(SQLITECPP_OBJS)
	@mkdir -p $(dir $@)
	@ar rcs $@ $^

run: all
	@set -e; for t in $(BINS); do "$$t"; done

clean:
	rm -rf $(BUILD)

-include $(shell find $(BUILD) -name '*.d' 2>/dev/null)
