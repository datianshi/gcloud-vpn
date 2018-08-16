resource "google_compute_forwarding_rule" "lb" {
  name       = "internal-lb"
  load_balancing_scheme = "INTERNAL"
  region = "us-west1"
  ports = ["80"]
  network = "${google_compute_network.test_west.self_link}"
  subnetwork = "${google_compute_subnetwork.test_subnet_west.self_link}"
  ip_address = "${var.internal_lb_address}"

  backend_service = "${google_compute_region_backend_service.http_lb_backend_service.self_link}"
}

resource "google_compute_region_backend_service" "http_lb_backend_service" {
  name        = "internal-http"
  protocol    = "TCP"
  region = "us-west1"
  timeout_sec = 10

  backend {
    group = "${google_compute_instance_group.httplb.self_link}"
  }

  health_checks = ["${google_compute_health_check.health_check.self_link}"]
}

resource "google_compute_instance_group" "httplb" {
  name        = "instance-group"
  description = "Instance Group for load balancer"
  zone        = "us-west1-b"
  network = "${google_compute_network.test_west.self_link}"
  instances = ["${google_compute_instance.ubuntu_west.self_link}"]
}

resource "google_compute_health_check" "health_check" {
  name                = "hk"
  check_interval_sec  = 50
  timeout_sec         = 3
  healthy_threshold   = 6
  unhealthy_threshold = 3

  http_health_check {
    port                = 80
    request_path        = "/"
  }
}
