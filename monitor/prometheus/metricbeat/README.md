# Welcome to Metricbeat 8.15.0

Metricbeat is a lightweight shipper for metrics.

## Getting Started

To get started with Metricbeat, you need to set up Elasticsearch on
your localhost first. After that, start Metricbeat with:

     ./metricbeat -c metricbeat.yml -e

This will start Metricbeat and send the data to your Elasticsearch
instance. To load the dashboards for Metricbeat into Kibana, run:

    ./metricbeat setup -e

For further steps visit the
[Quick start](https://www.elastic.co/guide/en/beats/metricbeat/main/metricbeat-installation-configuration.html) guide.

## Documentation

Visit [Elastic.co Docs](https://www.elastic.co/guide/en/beats/metricbeat/main/index.html)
for the full Metricbeat documentation.

## Release notes

https://www.elastic.co/guide/en/beats/libbeat/main/release-notes-8.15.0.html
