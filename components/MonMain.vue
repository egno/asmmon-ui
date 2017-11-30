<template>
  <div :style="{height:height,width:width}">
    <loading-bar
    :title="'До обновления данных ' + refreshTime + ' сек.'"
    :progress="refreshTimePercent"
    :on-error-done="errorDone"
    :on-progress-done="progressDone"
    :error="false"
    ></loading-bar>
    <mon-cards
    width="100%"
    height="20em"
    :data="current"
    ></mon-cards>
    <div v-if="!current" class="note">
      <h1>Данные не получены</h1>
    </div>
    <mon-lines v-if="series && timeTicks"
    width="100%"
    height="30em"
    :title="title"
    :xAxisData="timeTicks"
    :series="series"
    :legend="legend"
    :minLevel="2000"
    :id="'chart_' + server"
    >
    </mon-lines>
    <mon-progress
    v-if="current"
    width="98%"
    height="1.5em"
    :state="speedAttention"
    :value="doneProgress"
    :title="doneProgressText"
    ></mon-progress>
    <mon-tiles v-if="current"
    :data="stations"
    ></mon-tiles>
    <!-- <button >{{ this.timeCounters.counters.normal }}</button> -->
    <div class="note" v-if="note">
      {{ note }}
    </div>
    <div class="error note" v-if="queryError">
      {{ queryError }}
    </div>
    <notes v-if="current"></notes>
  </div>
</template>

<script>
import MonLines from '~/components/MonLines.vue'
import MonCards from '~/components/MonCards.vue'
import MonTiles from '~/components/MonTiles.vue'
import MonProgress from '~/components/MonProgress.vue'
import LoadingBar from 'vue2-loading-bar'
import Notes from '~/components/Notes.vue'
const axios = require('axios')

export default {
  props: {
    width: {
      type: String,
      default: '800px'
    },
    height: {
      type: String,
      default: '600px'
    },
    avg: {
      default () {
        return 12
      }
    },
    hoursAgo: {
      default: 24
    },
    partCount: {
      default: 50
    },
    timeMinutesInterval: {
      default: 5
    },
    timer: {
      default () {
        return {
          counters: {
            normal: 60
          },
          stations: {
            normal: 60
          }
        }
      }
    },
    server: {
      default: 'NSK'
    },
    url: {
      default: '/api/v1/'
    }
  },
  data () {
    return {
      legend: [
        'Скорость сборки (поз./час) - approx. 5 min.',
        'Скорость сборки (поз./час)',
        'Средняя скорость (поз./час)',
        'Рекомендуемая скорость (поз./час)'
      ],
      history: {},
      counter: [0, 0],
      timeCounters: {
        counters: {
          normal: 0
        },
        stations: {
          normal: 0
        }
      },
      refreshTime: 0,
      countData: 40,
      interval: null,
      loadedCurrent: null,
      note: '',
      servers: null,
      stations: null,
      queryInProcess: 0,
      queryError: ''
    }
  },
  components: {
    MonLines,
    MonCards,
    MonTiles,
    MonProgress,
    LoadingBar,
    Notes
  },
  computed: {
    city () {
      if (!this.servers) return
      return this.servers.filter(x => x.code === this.server)[0]
    },
    current () {
      if (!this.loadedCurrent) return
      let current = {}
      Object.assign(current, this.loadedCurrent)
      current.ASMEndTimePlanT = new Date(current.ASMEndTimePlan)
      const hoursLeft = Math.max(
        (current.ASMEndTimePlanT.getTime() - new Date(current.CntDateMax.replace(' ', 'T')).getTime()), 0
      ) / 60000 / 60
      current.RSpeed = (hoursLeft)
        ? Math.round((current.PosASMAll - current.PosASMEnd) / hoursLeft, 0)
        : 0
      const CShiftValues = this.times.map(x => this.history[this.dateToString(x)])
        .filter(x => (x) && x.CShift === current.CShift && x.PosASM60min && (new Date(x.CntDateMax.replace(' ', 'T')) <= new Date(current.CntDateMax.replace(' ', 'T'))))
        .map(x => x.PosASM60min)
      current.AVG_PosASM = Math.round(
        CShiftValues.reduce((r, x) => r + x, 0) / CShiftValues.length,
        0)
      current.AVG_PosASM60min = Math.round(
        this.AVG_PosASM60min(current, this.values)
      )
      current.ASMEndTimeFactT = (current.PosASMAll > current.PosASMEnd)
        ? new Date(
          new Date(current.CntDateMax.replace(' ', 'T')).getTime() +
          (current.PosASMAll - current.PosASMEnd) / current.AVG_PosASM60min * 60000 * 60
        )
        : current.ASMEndTimePlanT
      current.ASMEndTimeFact = this.dateToString(current.ASMEndTimeFactT)
      return current
    },
    doneProgress () {
      if (!this.current) return 0
      return this.current.PosASMEnd / this.current.PosASMAll
    },
    doneProgressText () {
      if (!this.current) return
      if (!this.current.PosASMAll) return
      return '' + Math.round((this.doneProgress * 100), 1) + '% (' + this.current.PosASMEnd + ' из ' + this.current.PosASMAll + ')'
    },
    maxRefreshTime () {
      return this.timeMinutesInterval * 60
    },
    needToFillData () {
      if (!this.values) return false
      return !!this.values.filter(x => !x.state).length
    },
    refreshTimePercent () {
      return this.refreshTime / this.maxRefreshTime * 100
    },
    series () {
      if (!this.values) return
      return [
        this.values.map(x => x.PosASM60min),
        this.values.map((x, i, arr) => Math.round(this.AVG_PosASM60min(x, arr) || 0) || 0),
        this.values.map(x => this.current.AVG_PosASM || 0),
        this.values.map(x => this.current.RSpeed)
      ]
    },
    speedAttention () {
      if (!this.current) return
      return (this.current.AVG_PosASM60min < this.current.RSpeed) ? 'attention' : 'normal'
    },
    times () {
      if (!this.loadedCurrent) return
      return Array.apply(0, Array(this.hoursAgo * 60 / this.timeMinutesInterval)).map((x, i, arr) => new Date(new Date(this.loadedCurrent.CntDateMax.replace(' ', 'T')).getTime() - (arr.length - i - 1) * this.timeMinutesInterval * 60000))
    },
    timeTicks () {
      if (!this.times) return
      return this.times.map(x => {
        let dateString = this.dateToString(x)
        if (!dateString) return
        return this.dateToString(x).slice(11)
      })
    },
    title () {
      return 'График сборки' + (
        ((this.city) ? ' - ' + this.city.caption : '') +
        ((this.current) ? ': ' + this.current.CntDateMax : '')
      )
    },
    values () {
      if (!this.times) return
      return this.times.map((x) => {
        let CntDateMax = this.dateToString(x)
        return this.history[CntDateMax] ||
          {
            CntDateMax: CntDateMax
          }
      })
    }
  },
  methods: {
    AVG_PosASM60min (current, arr) {
      if (!current.CntDateMax) return
      const ago60min = this.dateToString(new Date(new Date(current.CntDateMax.replace(' ', 'T')).getTime() - 60 * 60000))
      const filtered = arr.filter(x => x.CntDateMax <= current.CntDateMax && x.CntDateMax >= ago60min)
        .sort((a, b) => (a.CntDateMax > b.CntDateMax) ? 1 : -1)
        .slice(-this.avg)
        .filter((x) => (x.CShift) && (x.CShift === current.CShift))
        .map(x => x.PosASM60min || 0)
      if (!filtered.length) return
      let res = filtered.reduce((r, x) => (+r || 0) + (+x || 0), 0) / filtered.length
      return res || 0
    },
    clearHistory () {
      const minTime = this.dateToString(this.times[0])
      for (let key of Object.keys(this.history)) {
        if (key < minTime) {
          delete this.history[key]
        }
      }
    },
    dateToString (dt) {
      function padStr (i) {
        return (i < 10) ? '0' + i : '' + i
      }
      const nullDate = new Date(null)
      if (!dt || isNaN(dt.getFullYear()) || dt.getTime() === nullDate.getTime()) return
      return padStr(dt.getFullYear()) + '-' +
        padStr(1 + dt.getMonth()) + '-' +
        padStr(dt.getDate()) + ' ' +
        padStr(dt.getHours()) + ':' +
        padStr(dt.getMinutes())
    },
    errorDone () {
    },
    progressDone () {
    },
    getCounters (count = 1, time = '', start) {
      this.queryError = ''
      this.note = 'Запрос данных...'
      this.queryInProcess += 1
      axios.get(this.url + 'counters/' + this.server + '/?count=' + count + '&time=' + time)
        .then((res) => {
          if (!time) {
            if (!this.loadedCurrent || (this.loadedCurrent && res.data[0].CntDateMax !== this.loadedCurrent.CntDateMax)) {
              this.refreshTime = this.maxRefreshTime
            }
            this.loadedCurrent = res.data[0]
          } else {
            this.setHistoryItemsState(
              'success',
              start,
              time
            )
          }
          res.data.map((x, i, arr) => {
            x.state = 'success'
            this.$set(this.history, x.CntDateMax, x)
            return x
          })
          this.queryInProcess -= 1
          this.note = ''
        })
        .catch((err) => {
          this.note = ''
          this.queryError = 'Нет ответа от сервера'
          if (time) {
            this.setHistoryItemsState(
              'fail',
              start,
              time
            )
          }
          this.queryInProcess -= 1
          console.log(err)
        })
    },
    getServers () {
      axios.get(this.url + '')
        .then((res) => {
          this.servers = res.data.sort((a, b) => (a.caption > b.caption) ? 1 : -1)
          this.queryError = ''
        })
        .catch((err) => {
          this.queryError = 'Нет ответа от сервера'
          console.log(err)
        })
    },
    getStations () {
      this.queryError = ''
      this.note = 'Запрос данных...'
      // this.queryInProcess += 1
      axios.get(this.url + 'stations/' + this.server + '/')
        .then((res) => {
          res.data = res.data.map((x) => {
            x.stations = x.StationName.split(',').map((sx) => sx.trim())
            return x
          })
          let stations = res.data
            .map((x) => x.stations)
            .reduce((r, x) => [...new Set(r.concat(x))], [])
            .sort((a, b) => (a > b) ? 1 : -1)
            .map(x => res.data
              .filter(dx => dx.stations.indexOf(x) > -1)
              .reduce((dr, dx) => {
                dr.StationName = dr.StationName || x
                dr.StationRealName = dr.StationRealName || x
                dr.DownTime = ((dr.DownTime || 1000) > (dx.DownTime || 0)) ? dx.DownTime : dr.DownTime
                dr.MinValue = ((dr.MinValue || 1000) > (dx.MinValue || 0)) ? dx.MinValue : dr.MinValue
                dr.MinValueReal = ((dr.MinValueReal || 1000) > (dx.MinValueReal || 0)) ? dx.MinValueReal : dr.MinValueReal
                dr.MaxValue = ((dr.MaxValue || 0) < dx.MaxValue) ? dx.MaxValue : dr.MaxValue
                dr.CntValue = ((dr.CntValue || 0) < dx.CntValue) ? dx.CntValue : dr.CntValue
                dr.AlertDiff = ((dr.AlertDiff || 0) < dx.AlertDiff) ? dx.AlertDiff : dr.AlertDiff
                dr.WarningDiff = ((dr.WarningDiff || 0) < dx.WarningDiff) ? dx.WarningDiff : dr.WarningDiff
                return dr
              }, {})
            )
          this.stations = stations.sort((a, b) =>
            ((Number(a.StationName) || 0) === (Number(b.StationName) || 0))
              ? (a.StationName > b.StationName) ? 1 : -1
              : (Number(a.StationName) > Number(b.StationName)) ? 1 : -1
          )
          // this.queryInProcess -= 1
          this.note = ''
        })
        .catch((err) => {
          this.note = ''
          this.queryError = 'Нет ответа от сервера'
          // this.queryInProcess -= 1
          console.log(err)
        })
    },
    loadAllHistoryParts () {
      if (!this.history) return
      if (Object.keys(this.history).length > this.values.length) {
        this.clearHistory()
      }
      if (!this.needToFillData || this.queryInProcess) return
      // console.log('load all')
      let i = this.values.length - 1
      while (i >= 0) {
        this.getCounters(this.partCount, this.values[i].CntDateMax, this.values[Math.max(i - this.partCount, 0)].CntDateMax)
        i -= this.partCount
      }
    },
    loadNextHistoryPart () {
      if (!this.values) return
      const emptyValues = this.values.filter(x => (!x.CShift))
      if (!emptyValues.length) return
      const queryDate = emptyValues[emptyValues.length - 1].CntDateMax
      this.getCounters(this.partCount, queryDate)
    },
    onStart () {
      document.title = 'ASM monitor - ' + this.city
      this.startTimer()
    },
    setHistoryItemsState (state, start, end) {
      this.values.map(x => {
        if (x.CntDateMax >= start && x.CntDateMax <= end) {
          this.$set(this.history, x.CntDateMax, this.history[x.CntDateMax] || {state: state})
        }
      })
    },
    stopTimer () {
      if (this.interval) {
        // console.log('stop', this.interval)
        window.clearInterval(this.interval)
      }
    },
    startTimer () {
      function tick (counter, timer) {
        return (counter + timer - 1) % timer
      }
      this.stopTimer()
      this.interval = window.setInterval(() => {
        this.refreshTime = Math.max(this.refreshTime - 1, 0)
        this.timeCounters.counters.normal = tick(this.timeCounters.counters.normal, this.timer.counters.normal)
        this.timeCounters.stations.normal = tick(this.timeCounters.stations.normal, this.timer.stations.normal)
        if (!this.timeCounters.counters.normal) this.getCounters()
        if (!this.timeCounters.stations.normal) this.getStations()
      }, 1000)
    }
  },
  watch: {
    'current': 'loadAllHistoryParts',
    'server': 'onStart'
  },
  mounted () {
    this.getCounters()
    this.startTimer()
    this.getServers()
    this.getStations()
  },
  beforeDestroy () {
    this.stopTimer()
  }
}
</script>

<style>
body {
  background-color: black;
  color: #ccc
}
.note {
  margin: auto;
  text-align: center;
  color: #444;
}
.error {
  color: #900;
}
.LoadingBar {
  width: 98%;
  height: 5px;
  transition: all 0.6s ease-in-out;
}
.LoadingBar-glow {
  height: 100%;
  background-color: #070;
}
</style>
