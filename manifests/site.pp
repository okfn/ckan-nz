node default {
  exec { "apt-get update":
    command => "/usr/bin/apt-get update",
  }

  Exec['apt-get update'] -> Package <| |>

  class { 'ckan':
    site_url              => 'test.ckan.com',
    site_title            => 'CKAN Test',
    site_description      => 'A shared environment for managing Data.',
    site_intro            => 'A CKAN test installation',
    site_about            => 'Pilot data catalogue and repository.',
    plugins               => 'stats text_preview recline_preview datastore resource_proxy pdf_preview spatial_metadata spatial_query hierarchy_form hierarchy_display googleanalytics',
    is_ckan_from_repo     => false,
    ckan_package_url      => 'http://packaging.ckan.org/python-ckan_2.2_amd64.deb',
    ckan_package_filename => 'python-ckan_2.2_amd64.deb',
  }

  class { 'ckan::ext::googleanalytics':
    id       => 'UA-12345-X',
    account  => 'example.com',
    username => 'joebloggs@example.com',
    password => 'password123',
  }
  class { 'ckan::ext::hierarchy': }
  class { 'ckan::ext::spatial': }
}
