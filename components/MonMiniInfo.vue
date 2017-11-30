<template>
  <div class="mini-tile" :style="{height:height,width:width}" title="Перейти к графику скорости сборки">
    <mon-card
    width="12em"
    height="6.2em"
    :title="title"
    :subtitle="subtitle"
    :values="displayData"
    :titles="titles"
    ></mon-card>
    <div class="note" v-if="note">
      {{ note }}
    </div>
    <div class="error note" v-if="queryError">
      {{ queryError }}
    </div>
  </div>
</template>

<script>
import MonCard from '~/components/MonCard.vue'
const axios = require('axios')

export default {
  props: {
    width: {
      type: String,
      default: '200px'
    },
    height: {
      type: String,
      default: '100px'
    },
    timer: {
      default () {
        return {
          counters: {
            normal: 60
          }
        }
      }
    },
    title: {
      default: ''
    },
    server: {
      default: 'BRD'
    },
    url: {
      default: '/api/v1/'
    }
  },
  data () {
    return {
      timeCounters: {
        counters: {
          normal: 0
        }
      },
      loadedCurrent: null,
      queryInProcess: 0,
      queryError: '',
      note: '',
      titles: {
        title: 'Перейти к графику скорости сборки',
        subtitle: 'Время последнего обновления данных (в часовом поясе филиала)',
        values: 'Текущая скорость сборки, позиций в час'
      }
    }
  },
  components: {
    MonCard
  },
  computed: {
    displayData () {
      if (!this.current) return
      return this.current.AVG_PosASM
    },
    subtitle () {
      if (!this.current) return
      return this.current.CntDateMax
    },
    current () {
      if (!this.loadedCurrent) return
      let result = this.loadedCurrent[0]
      let filteredData = this.loadedCurrent.filter(x => x.CShift === result.CShift && (x.PosASM60min)).map(x => x.PosASM60min)
      result.AVG_PosASM = (filteredData.length) ? Math.round(filteredData
        .reduce((r, x) => r + x, 0) / filteredData.length) : 0
      return result
    }
  },
  methods: {
    getCounters (count = 12, time = '', start) {
      if (this.queryInProcess) return
      this.note = 'Запрос данных...'
      this.queryError = ''
      this.queryInProcess += 1
      axios.get(this.url + 'counters/' + this.server + '/?count=' + count + '&time=' + (time || '&noCache=' + (new Date().getTime()) + Math.random()))
        .then((res) => {
          this.loadedCurrent = res.data
          this.queryInProcess -= 1
          this.note = ''
        })
        .catch((err) => {
          this.note = ''
          this.queryError = 'Нет ответа от сервера'
          this.queryInProcess -= 1
          console.log(err)
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
        this.timeCounters.counters.normal = tick(this.timeCounters.counters.normal, this.timer.counters.normal)
        // this.timeCounters.stations.normal = tick(this.timeCounters.stations.normal, this.timer.stations.normal)
        if (!this.timeCounters.counters.normal) this.getCounters()
        // if (!this.timeCounters.stations.normal) this.getStations()
      }, 1000)
    }
  },
  watch: {
    // 'current': 'loadAllHistoryParts',
    'server': 'startTimer'
  },
  mounted () {
    this.getCounters()
    this.startTimer()
  },
  beforeDestroy () {
    this.stopTimer()
  }
}
</script>

<style>
.mini-tile {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  justify-content: space-around;
  align-content: space-around;
  align-content: flex-start;
  margin: 1em;
}
.note {
  margin: auto;
  text-align: center;
  color: #444;
  font-size: 0.7em;
}
.error {
  color: #900;
}
.card-title {
  color: #999;
}
</style>
