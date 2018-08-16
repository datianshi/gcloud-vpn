resource "google_compute_vpn_gateway" "target_gateway_east" {
  name    = "vpn-east"
  network = "${google_compute_network.test_east.self_link}"
  region  = "us-east1"
}

resource "google_compute_vpn_gateway" "target_gateway_west" {
  name    = "vpn-west"
  network = "${google_compute_network.test_west.self_link}"
  region  = "us-west1"
}

resource "google_compute_address" "east_vpn_static_ip" {
  name   = "vpn-static-ip-east"
  region = "us-east1"
}

resource "google_compute_address" "west_vpn_static_ip" {
  name   = "vpn-static-ip-west"
  region = "us-west1"
}

resource "google_compute_forwarding_rule" "fr_esp_east" {
  name        = "fr-esp-east"
  region      = "us-east1"
  ip_protocol = "ESP"
  ip_address  = "${google_compute_address.east_vpn_static_ip.address}"
  target      = "${google_compute_vpn_gateway.target_gateway_east.self_link}"
}

resource "google_compute_forwarding_rule" "fr_udp500_east" {
  name        = "fr-udp500-east"
  region      = "us-east1"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = "${google_compute_address.east_vpn_static_ip.address}"
  target      = "${google_compute_vpn_gateway.target_gateway_east.self_link}"
}

resource "google_compute_forwarding_rule" "east_fr_udp4500" {
  provider= "google"
  name        = "east-fr-udp4500"
  region      = "us-east1"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = "${google_compute_address.east_vpn_static_ip.address}"
  target      = "${google_compute_vpn_gateway.target_gateway_east.self_link}"
}

resource "google_compute_forwarding_rule" "fr_esp_west" {
  name        = "fr-esp-west"
  region      = "us-west1"
  ip_protocol = "ESP"
  ip_address  = "${google_compute_address.west_vpn_static_ip.address}"
  target      = "${google_compute_vpn_gateway.target_gateway_west.self_link}"
}

resource "google_compute_forwarding_rule" "fr_udp500_west" {
  name        = "fr-udp500-west"
  region      = "us-west1"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = "${google_compute_address.west_vpn_static_ip.address}"
  target      = "${google_compute_vpn_gateway.target_gateway_west.self_link}"
}

resource "google_compute_forwarding_rule" "west_fr_udp4500" {
  provider= "google"
  name        = "west-fr-udp4500"
  region      = "us-west1"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = "${google_compute_address.west_vpn_static_ip.address}"
  target      = "${google_compute_vpn_gateway.target_gateway_west.self_link}"
}

resource "google_compute_vpn_tunnel" "tunnel_east" {
  provider= "google"
  name          = "east-tunnel"
  region      = "us-east1"
  peer_ip       = "${google_compute_address.west_vpn_static_ip.address}"
  shared_secret = "${var.shared_secret}"
  ike_version = "1"

  local_traffic_selector  = ["${var.east_cidr}"]
  remote_traffic_selector = ["${var.west_cidr}"]

  target_vpn_gateway = "${google_compute_vpn_gateway.target_gateway_east.self_link}"

  depends_on = [
    "google_compute_forwarding_rule.fr_esp_east",
    "google_compute_forwarding_rule.fr_udp500_east",
    "google_compute_forwarding_rule.east_fr_udp4500",
  ]
}

resource "google_compute_vpn_tunnel" "tunnel_west" {
  provider= "google"
  name          = "west-tunnel"
  region      = "us-west1"
  peer_ip       = "${google_compute_address.east_vpn_static_ip.address}"
  shared_secret = "${var.shared_secret}"
  ike_version = "1"

  local_traffic_selector  = ["${var.west_cidr}"]
  remote_traffic_selector = ["${var.east_cidr}"]

  target_vpn_gateway = "${google_compute_vpn_gateway.target_gateway_west.self_link}"

  depends_on = [
    "google_compute_forwarding_rule.fr_esp_east",
    "google_compute_forwarding_rule.fr_udp500_east",
    "google_compute_forwarding_rule.east_fr_udp4500",
  ]
}
