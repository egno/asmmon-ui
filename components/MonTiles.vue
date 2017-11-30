<template>
  <div :class="className" :id="id" :style="{height:height,width:width}">
    <div v-if="data" class="tile-container" title="Количество корзин, прошедших через зону за последнюю минуту">
      <mon-tile v-for="item in data"
      :key="item.StationName"
      :title="item.StationName"
      :value="alertTime(item)"
      :state="state(item)"
      :note="note(item)"
      ></mon-tile>
    </div>
  </div>
</template>

<script>
import MonTile from '~/components/MonTile.vue'
export default {
  props: {
    className: {
      type: String,
      default: 'tiles'
    },
    id: {
      type: String,
      default: 'tiles'
    },
    width: {
      type: String,
      default: '100%'
    },
    height: {
      type: String,
      default: 'auto'
    },
    data: null
  },
  data () {
    return {
      title: ''
    }
  },
  components: {
    MonTile
  },
  methods: {
    alertTime (item) {
      if (item.CntValue) return
      return (item.DownTime > 60) ? '>60' : item.DownTime
    },
    note (item) {
      if (!item) return
      return 'Зона ' + (item.StationRealName || item.StationName) + ': ' + (item.CntValue || 0) +
        ' (MIN: ' + item.MinValueReal + ' MAX: ' + item.MaxValue + ')' +
        ((this.alertTime(item)) ? (' Простой: ' + this.alertTime(item)) + ' мин.' : '')
    },
    state (item) {
      if (!item) return
      if (!item.CntValue && (item.DownTime > 60)) return 'Offline'
      if (
        (item.CntValue >= item.MaxValue)
      ) return 'MaxAlert'
      if (
        (item.CntValue >= (item.MaxValue - (item.WarningDiff || 0)))
      ) return 'MaxWarning'
      if (
        (!item.CntValue) ||
        (item.CntValue < item.MinValueReal)
      ) return 'MinAlert'
      if (
        (item.CntValue < (item.MinValueReal + (item.WarningDiff || 0)))
      ) return 'MinWarning'
      return 'Normal'
    }
  }
}
</script>

<style>
.tile-container {
  height: 100%;
  font-size: 0.8em;
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  justify-content: center;
  margin: 1em;
}
</style>
