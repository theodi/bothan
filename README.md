# ODI Metrics API

[![Build Status](http://jenkins.theodi.org/buildStatus/icon?job=metrics-api-master)](http://jenkins.theodi.org/job/metrics-api-master/)
[![Dependency Status](https://gemnasium.com/theodi/metrics-api.png)](https://gemnasium.com/theodi/metrics-api)
[![Code Climate](https://codeclimate.com/github/theodi/metrics-api.png)](https://codeclimate.com/github/theodi/metrics-api)

A simple wrapper around MongoDB to allow storage of time series metrics.

# Fetching data

All requests should include `Content-type: application/json`.

```
GET https://metrics.theodi.org/metrics[.json]
```

Fetches list of available metrics

```
GET https://metrics.theodi.org/metrics/{metric_name}[.json]
```

Fetches latest value for specified metric

```
GET https://metrics.theodi.org/metrics/{metric_name}/{time}
```

Fetch the most recent value of the metric at the specified time. `time` is an ISO8601 date/time.

```
GET https://metrics.theodi.org/metrics/{metric_name}/{from}/{to}
```

Fetch all values of the metric between the specified times. `from` and `to` can be either:

 * An ISO8601 date/time
 * An ISO8601 duration
 * `*`, meaning unspecified

# Adding data

```
POST https://metrics.theodi.org/metrics/{metric-name}
```

using a JSON content type, and with the following JSON in the body:

```
{
  "name": "{metric-name}",
  "time": "{iso8601-date-time}",
  "value": ...
}
```

`value` is any valid JSON structure or number.
}
