{ pkgs, devshell }:
{
  environ-1 =
    let
      shell = devshell.mkShell {
        devshell.name = "environ";
        environ = [
          {
            name = "HTTP_PORT";
            value = 8080;
          }
          {
            name = "PATH";
            prefix = "bin";
          }
          {
            name = "XDG_CACHE_DIR";
            eval = "$DEVSHELL_ROOT/$(echo .cache)";
          }
        ];
      };
    in
    pkgs.runCommand "environ-1" { } ''
      unset XDG_DATA_DIRS

      source ${./assert.sh}

      # Load the devshell
      source ${shell}

      # NIXPKGS_PATH is being set
      assert "$NIXPKGS_PATH" == "${toString pkgs.path}"

      assert "$XDG_DATA_DIRS" == "$DEVSHELL_DIR/share:/usr/local/share:/usr/share"

      assert "$HTTP_PORT" == 8080

      # PATH is prefixed with an expanded bin folder
      [[ $PATH == $PWD/bin:* ]]

      # Eval
      assert "$XDG_CACHE_DIR" == "$PWD/.cache"

      touch $out
    '';
}
