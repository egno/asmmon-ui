<template>
  <div :class="className" :id="id" :style="{height:height,width:width}">
    <div v-if="data" class="tile-container">
      <mon-tile v-for="item in data"
      :key="item.StationName"
      :title="(item.StationRealName || item.StationName)"
      :value="item.CntValue"
      :state="state(item)"
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
    state (item) {
      if (!item) return
      if (
        (item.CntValue >= (item.MaxValue + item.AlertDiff))
      ) return 'MaxAlert'
      if (
        (item.CntValue >= (item.MaxValue + item.WarningDiff))
      ) return 'MaxWarning'
      if (
        (!item.CntValue) ||
        (item.CntValue < (item.MinValueReal - item.AlertDiff))
      ) return 'MinAlert'
      if (
        (item.CntValue < (item.MinValueReal - item.WarningDiff))
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
