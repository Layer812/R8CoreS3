# tools/Makefile

CXX = g++
CXXFLAGS = -O2 -Wall -std=c++17

# PlatformIOのz8luaライブラリのパスをプロジェクト構造に合わせて指定します
# ※必要に応じて、プロジェクトルートからの相対パスに調整してください
INCLUDES = -I../lib/3rdparty/z8lua -I../src/pico8 -I../src

# リンクするオブジェクトファイルや静的ライブラリがあれば指定（なければソースを直接固めます）
# PlatformIOでビルドされたz8luaのオブジェクトファイルをそのまま流用するか、
# z8luaのソースコード（*.c）を一緒にコンパイルします
TARGET = pc8_compile

all: $(TARGET)

$(TARGET): pc8_compile.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) pc8_compile.cpp -o $(TARGET) -ldl -lm

clean:
	rm -f $(TARGET)
