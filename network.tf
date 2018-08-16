resource "google_compute_network" "test_east" {
  name                    = "test-east"
  auto_create_subnetworks = "false"
}

resource "google_compute_network" "test_west" {
  name                    = "test-west"
  auto_create_subnetworks = "false"
}

resource "google_compute_firewall" "test_east" {
  name    = "test-allow-ssh-east"
  network = "${google_compute_network.test_east.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "22"]
  }

}

resource "google_compute_firewall" "test_west" {
  name    = "test-allow-ssh-west"
  network = "${google_compute_network.test_west.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "22"]
  }

}

resource "google_compute_subnetwork" "test_subnet_east" {
  name          = "testsubneteast"
  ip_cidr_range = "${var.east_cidr}"
  network       = "${google_compute_network.test_east.self_link}"
  region        = "us-east1"
}

resource "google_compute_subnetwork" "test_subnet_west" {
  name          = "testsubnetwest"
  ip_cidr_range = "${var.west_cidr}"
  network       = "${google_compute_network.test_west.self_link}"
  region        = "us-west1"
}


resource "google_compute_firewall" "test_internal_east" {
  name    = "test-allow-internal-east"
  network = "${google_compute_network.test_east.name}"
  source_ranges= ["${var.west_cidr}", "${var.east_cidr}"]

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["1-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["1-65535"]
  }

  source_tags = ["internal"]
}

resource "google_compute_firewall" "test_internal_west" {
  name    = "test-allow-internal-west"
  network = "${google_compute_network.test_west.name}"
  source_ranges= ["${var.west_cidr}", "${var.east_cidr}"]

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["1-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["1-65535"]
  }

  source_tags = ["internal"]
}

# resource "google_compute_firewall" "internal_lb" {
#   name    = "internal-lb"
#   network = "${google_compute_network.test_west.name}"
#   source_ranges= ["10.128.0.0/20", "130.211.0.0/22", "35.191.0.0/16"]
#   target_tags = ["int-lb"]
#
#   allow {
#     protocol = "icmp"
#   }
#
#   allow {
#     protocol = "tcp"
#     ports    = ["1-65535"]
#   }
#
#   allow {
#     protocol = "udp"
#     ports    = ["1-65535"]
#   }
#
# }

resource "google_compute_route" "route_vpn_east" {
  name        = "vpnroute-east"
  dest_range  = "${var.west_cidr}"
  network     = "${google_compute_network.test_east.name}"
  next_hop_vpn_tunnel = "${google_compute_vpn_tunnel.tunnel_east.self_link}"
  priority    = 100
}

resource "google_compute_route" "route_vpn_west" {
  name        = "vpnroute-west"
  dest_range  = "${var.east_cidr}"
  network     = "${google_compute_network.test_west.name}"
  next_hop_vpn_tunnel = "${google_compute_vpn_tunnel.tunnel_west.self_link}"
  priority    = 100
}
