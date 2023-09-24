swift(){
        IMAGE=docker.io/library/swift:latest
        while [[ $# -gt 0 ]]; do
        case $1 in
                -v|--version)
                        podman run -it --rm --tz=Europe/Paris ${IMAGE} swift --version
                        shift
                        ;;
                *)
                        podman run -it --rm -u=root -v=$PWD:/root:z --tz=Europe/Paris ${IMAGE} swift $1 --package-path /root
                        shift
                        ;;
        esac
        done
}
