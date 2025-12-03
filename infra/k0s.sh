#!/bin/bash
# k0s-lab.sh: Setup or reset k0s lab environment
set -e

function stop_docker() {
  echo "Stopping Docker..."
  sudo systemctl stop docker.socket || true
  sudo systemctl stop docker || true
  sudo systemctl status docker --no-pager || true
  echo ""
}

function clean_iptables() {
  echo "Cleaning up Docker iptables rules..."
  sudo iptables -P INPUT ACCEPT || true
  sudo iptables -P FORWARD ACCEPT || true
  sudo iptables -P OUTPUT ACCEPT || true
  sudo iptables -t nat -F || true
  sudo iptables -t mangle -F || true
  sudo iptables -F || true
  sudo iptables -X || true
  sudo iptables -F DOCKER || true
  sudo iptables -F DOCKER-USER || true
  sudo iptables -F FORWARD || true
  sudo iptables -X DOCKER || true
  sudo iptables -X DOCKER-USER || true
  echo ""
}

function install_k0s() {
  if ! command -v k0s &> /dev/null; then
    echo "Installing k0s..."
    curl -sSL https://get.k0s.sh | sudo bash
  fi
  echo ""
}

function start_k0s() {
  echo "Starting k0s controller..."
  sudo k0s install controller --single || true
  sudo k0s start || true
  sudo mount --make-rshared /
  echo "Lab only: to co-exist with Docker at restart, we are preventing k0scontroller systemd service to restart at boot..."
  sudo systemctl disable k0scontroller || true
  echo ""
}

function export_kubeconfig() {
  echo "Exporting kubeconfig..."
  sudo k0s kubeconfig admin > ~/.kube/config
  echo ""
}

function show_status() {  
  echo "Waiting for k0s API server to be ready..."
  until sudo k0s status &>/dev/null; do
    sleep 2
    echo -n "."
  done

  echo "k0s status:"
  sudo k0s status || true
  echo "k0s is up and kubectl can connect."
  echo ""
}

function remove_k0s_data() {
  echo "Stopping k0s..."
  sudo k0s stop || true
  echo "Stopping k0scontroller systemd service..."
  sudo systemctl stop k0scontroller || true
  echo "Removing k0s data..."
  sudo rm -rf /var/lib/k0s/kubelet/pods/* /etc/k0s/* /var/log/k0s/*
  sudo k0s stop || true
  echo ""
}

function remove_kubeconfig() {
  echo "Removing kubeconfig..."
  rm -f ~/.kube/config
  echo ""
}

function restart_k0s() {
  echo "Restarting k0s controller..."
  sudo systemctl restart k0scontroller || true
  sudo systemctl status k0scontroller --no-pager || true
  echo "k0s controller restarted."
  echo ""
}

function reset_k0s() {
  echo "Resetting k0s..."
  sudo k0s reset || true
  echo "k0s reset complete."
  echo ""
}

case "$1" in
  setup)
    stop_docker
    clean_iptables
    install_k0s
    start_k0s
    export_kubeconfig
    show_status
    echo "Environment setup complete. You can now use kubectl and proceed with the labs."
    ;;
  reset)
    remove_k0s_data
    clean_iptables
    remove_kubeconfig
    reset_k0s
    sleep 5
    start_k0s
    sleep 5
    export_kubeconfig
    show_status
    echo "k0s and environment reset complete. You can now use kubectl and proceed with the labs."
    ;;
  restart)
    stop_docker
    clean_iptables
    restart_k0s
    sleep 5
    show_status
    echo "k0s and environment restart complete. You can now use kubectl and proceed with the labs."
    ;;
  *)
    echo "Usage: $0 {setup|reset|restart}"
    exit 1
    ;;
esac
