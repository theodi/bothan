---
layout: default
title: Visualisations
---

![Metrics view](/images/metric-page.png){: .screenshot}

Once you have data, you can then visualise it in a number of different ways, depending on the metric. You can explore these on your individual metrics page (for example [https://demo.bothan.io/metrics/simple-metric/](https://demo.bothan.io/metrics/simple-metric/)), or manipulate options via query strings.

You will also be able to copy and paste embed code for a metric as an iframe.

<hr />

## Showing a metric's visualisation

```
GET https://demo.bothan.io/metrics/{metric_name}/{from}/{to}
```

(or `GET https://demo.bothan.io/metrics/{metric_name}` which will redirect to a default time-range of the last 30 days)

#### query-string options

The rendering can be manipulated by the following query-string options:

#### type

One of:

  * `chart`, which renders a [Plotly](https://plot.ly/javascript/) line chart of the data: <br>
  <iframe src="https://demo.bothan.io/metrics/simple-metric?layout=bare&amp;boxcolour=2254f4&amp;textcolour=ffffff&amp;type=" width="100%" height="350px" frameborder="0" scrolling="no"></iframe>
  * `number`, which displays the latest value from the metric: <br>
  <iframe src="https://demo.bothan.io/metrics/simple-metric?layout=bare&amp;boxcolour=0dbc37&amp;textcolour=ffffff&amp;type=number" width="100%" height="350px" frameborder="0" scrolling="no"></iframe>
  * `pie`, which renders a [Plotly](https://plot.ly/javascript/) pie chart of the data, as best it can. This is only supported by the [multiple values](/api#multiple-values) metric type: <br>
  <iframe src="https://demo.bothan.io/metrics/metric-with-multiple-values?layout=bare&amp;boxcolour=ef3aab&amp;textcolour=ffffff&amp;type=pie" width="100%" height="350px" frameborder="0" scrolling="no"></iframe>
  * `target`, which renders a meter style chart with an actual value, an annual target value and a year to date target value. This is only supported by the [value with target](/api#value-with-target) metric type:<br>
  <iframe src="https://demo.bothan.io/metrics/metric-with-target?layout=bare&amp;boxcolour=ff6700&amp;textcolour=ffffff&amp;type=target" width="100%" height="350px" frameborder="0" scrolling="no"></iframe>
  * `map`, which renders a [Leaflet.js](http://leafletjs.com/) map rendering. This is only supported by the [geographical data](/api#geographical-data) metric type.<br>
  <iframe src="https://demo.bothan.io/metrics/metric-with-geodata?layout=bare&amp;type=map" width="100%" height="350px" frameborder="0" scrolling="no"></iframe>

Default: By default, Bothan will attempt to work out the best visualisation for your metric

#### layout

One of:

  * `rich`, with a nav-bar and other controls, or
  * `bare`, a minimal layout designed for inclusion elsewhere as an iframe

Default: `rich`

#### boxcolour

Background colour for the chart or number, in hex. Note that you should _not_ pass the leading _#_. Also note the English spelling

Default: `ddd`

#### textcolour

Text colour (and line colour for the chart), in hex. Note that you should _not_ pass the leading _#_. Also note the English spelling

Default: `222`

#### autorefresh

`meta-refresh` interval for the page

Default: `none`

#### title

The title for the metric. This defaults to a titleized version of the metric (for example, `my-cool-metric` will display as `My Cool Metric`)

Example: [https://demo.bothan.io/metrics/simple-metric?boxcolour=fa8100&textcolour=00ffff&layout=bare](https://demo.bothan.io/metrics/simple-metric?boxcolour=fa8100&textcolour=00ffff&layout=bare)

### tiles

The name of the tileset to use when visualising a map. Can be any one of the following (click to see a preview):

<ul id="tile-types"></ul>

<script>
  var excludes = ['HERE', 'MapBox', 'Thunderforest']
  var url = 'https://demo.bothan.io/metrics/metric-with-geodata/?layout=bare&type=map&tiles='
  for (var provider in L.TileLayer.Provider.providers) {
    if (excludes.includes(provider)) continue
    if (L.TileLayer.Provider.providers[provider].variants) {
      for (var variant in L.TileLayer.Provider.providers[provider].variants) {
        html = '<li><a href="'+ url + provider + '.' + variant +'">'+ provider + '.' + variant +'</a></li>'
        $('#tile-types').append(html);
      }
    } else {
      html = '<li><a href="'+ url + provider +'">'+ provider +'</a></li>'
      $('#tile-types').append(html);
    }
  }
</script>
