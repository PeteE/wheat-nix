# vim: ts=2:sw=2:et
{
  lib,
  fetchFromGitHub,
  pkgs,
  lua,
  ...
}:
lua.pkgs.buildLuarocksPackage {
    pname = "clickhouse-lua";
    version = "1.0.0-2";
    
    knownRockspec = "rockspecs/clickhouse-1.0.0-2.rockspec";
    src = fetchFromGitHub {
      owner = "EvandroLG";
      repo = "clickhouse-lua";
      rev = "e92f264795762eeb5dba1914b4e8d9cb2f7206db";
      sha256 = "sha256-IIFZobCA/7MJm5LVgu1gHUb4myG6ZFQZjmlVJFckjBE=";
    };
    propagatedBuildInputs = [
      lua
      lua.pkgs.luasocket
      lua.pkgs.cjson
    ];

    # The rockspec might not be in the repo, so we'll build manually
    buildPhase = ''
      # ClickHouse-lua is a simple pure Lua library, no compilation needed
    '';

    installPhase = ''
      mkdir -p $out/lib/lua/${lua.luaversion}/
      cp clickhouse_client.lua $out/lib/lua/${lua.luaversion}/clickhouse.lua
    '';
}
