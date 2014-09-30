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
    plugins               => 'stats text_preview recline_preview datastore resource_proxy pdf_preview spatial_metadata spatial_query hierarchy_form hierarchy_display googleanalytics newzealand_landcare',
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
  class { 'ckan::ext::newzealand': }

  file { '/etc/nginx/sites-available/ckan':
    content => '
proxy_cache_path /tmp/nginx_cache levels=1:2 keys_zone=cache:30m max_size=250m;
proxy_temp_path /tmp/nginx_proxy 1 2;

server {
    listen 80;
    listen 443 ssl;
    ssl_certificate /etc/ssl/certs/ssl-cert-snakeoil.pem;
    ssl_certificate_key /etc/ssl/private/ssl-cert-snakeoil.key;

    client_max_body_size 100M;

    location / {
        proxy_pass http://127.0.0.1:8080/;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Server $host;
        proxy_set_header X-Forwarded-Host $host;

        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Ssl $https;

        proxy_cache cache;
        proxy_cache_bypass $cookie_auth_tkt;
        proxy_no_cache $cookie_auth_tkt;
        proxy_cache_valid 30m;
        proxy_cache_key $host$scheme$proxy_host$request_uri;

        # In emergency comment out line to force caching
        # proxy_ignore_headers X-Accel-Expires Expires Cache-Control;

        add_header X-Robots-Tag "none, noarchive, nosnippet, noodp, notranslate, noimageindex";
    }
}',
    notify => Class['ckan::service'],
  }
}
