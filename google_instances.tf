resource "google_compute_instance" "ubuntu_east" {
  provider = "google"
  name         = "testeast"
  machine_type = "n1-standard-1"
  zone         = "us-east1-b"

  tags = ["ubuntu", "internal"]

  boot_disk {
    initialize_params {
      image = "ubuntu-1804-bionic-v20180814"
    }
  }

  scratch_disk {
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.test_subnet_east.name}"
    access_config {
    }
  }

  metadata {
    test = "yes"
  }

  metadata_startup_script = "${file("start_up.sh")}"

}



resource "google_compute_instance" "ubuntu_west" {
  name         = "testwest"
  machine_type = "n1-standard-1"
  zone         = "us-west1-b"

  tags = ["ubuntu", "internal"]

  boot_disk {
    initialize_params {
      image = "ubuntu-1804-bionic-v20180814"
    }
  }

  scratch_disk {
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.test_subnet_west.name}"
    access_config {
    }
  }

  metadata {
    test = "yes"
  }

  metadata_startup_script = "${file("start_up.sh")}"

}

resource "google_compute_instance" "ubuntu_central" {
  name         = "testcentral"
  machine_type = "n1-standard-1"
  zone         = "us-central1-b"

  tags = ["ubuntu", "internal"]

  boot_disk {
    initialize_params {
      image = "ubuntu-1804-bionic-v20180814"
    }
  }

  scratch_disk {
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.test_subnet_central.name}"
    access_config {
    }
  }

  metadata {
    test = "yes"
  }

  metadata_startup_script = "${file("start_up.sh")}"

}
