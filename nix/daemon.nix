{
  bc,
  bluos-controller-linux-patched,
  coreutils,
  daemon,
  electron,
  lib,
  nix-project-lib,
}:
{
  pname,
  version,
}:

let

  meta.description = "BluOS Controller ${version} (non-free)";
  meta.platforms = lib.platforms.linux ++ lib.platforms.darwin;
  app = "${bluos-controller-linux-patched}";

in
nix-project-lib.writeShellCheckedExe pname
  {
    inherit meta;
    pathPackages = [
      bc
      coreutils
      daemon
      electron
    ];
    pathIncludesPrevious = true;
  }
  ''
    set -eu
    set -o pipefail


    . "${nix-project-lib.scriptCommon}/share/nix-project/common.sh"


    COMMAND=start
    DAEMON_NAME=blue_controller
    SCALE="$(
        { echo "scale=1; $(xrdb -get dpi) / 115" | bc; } || echo 1
    )"
    ARGS=()


    print_usage()
    {
        cat - <<EOF
    USAGE: ${pname}
        [OPTIONS]... [start | start-nodaemon | stop | toggle] [-- DAEMON_ARGS...]

    DESCRIPTION:

        Runs the BluOS Controller, ensuring that there's only
        one instance running using a PID file.  This is done
        with the 'daemon' program.

        You can give a start or stop command.  Otherwise, start
        is assumed.  If you give both commands, the last one has
        precedence.

    OPTIONS:

        -h --help            print this help message
        -H --help-daemon     print this help message
        -s --scale           DPI scaling factor

    EOF
    }

    main()
    {
        while ! [ "''${1:-}" = "" ]
        do
            case "$1" in
            -h|--help)
                print_usage
                exit 0
                ;;
            -H|--help-daemon)
                daemon --help
                exit 0
                ;;
            -s|--scale)
                if [ -z "''${2:-}" ]
                then die "$1 requires an numeric argument"
                fi
                SCALE="''${2:-}"
                shift
                ;;
            --start|start)
                COMMAND=start
                ;;
            --start-nodaemon|start-nodaemon)
                COMMAND=start-nodaemon
                ;;
            --stop|stop)
                COMMAND=stop
                ;;
            --toggle|toggle)
                COMMAND=toggle
                ;;
            --)
                shift
                ARGS+=("$@")
                break
                ;;
            *) die "unrecognized command: $1" ;;
            esac
            shift
        done
        case "$COMMAND" in
        start)          start_controller          ;;
        start-nodaemon) start_nodaemon_controller ;;
        stop)           stop_controller           ;;
        toggle)         toggle_controller         ;;
        esac
    }

    start_controller()
    {
        daemon "''${ARGS[@]}" --name "$DAEMON_NAME" -- \
            electron --force-device-scale-factor="$SCALE" "${app}"
    }

    start_nodaemon_controller()
    {
        electron --force-device-scale-factor="$SCALE" "${app}"
    }

    stop_controller()
    {
        daemon "''${ARGS[@]}" --name "$DAEMON_NAME" --stop
    }

    toggle_controller()
    {
        if daemon --name "$DAEMON_NAME" --running
        then stop_controller
        else start_controller
        fi
    }

    die()
    {
        {
        print_usage
        echo
        echo "ERROR: $1"
        } >&2
    }


    main "$@"
  ''
