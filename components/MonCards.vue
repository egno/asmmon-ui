<template>
  <div :class="className" :id="id" :style="{height:height,width:width}">
    <div v-if="data" class="card-container">
      <mon-card
      title="Ожидаемое время окончания сборки"
      :values="data.ASMEndTimeFact || '---'"
      :attention='timeAttention'
      :titles="titles[0]"
      >
      </mon-card>
      <mon-card
      title="Время окончания сборки план."
      :values="data.ASMEndTimePlan || '---'"
      :titles="titles[1]"
      >
      </mon-card>
      <mon-card
      title="Осталось собрать / Общая нагрузка в позициях"
      :values="[data.PosASMAll - data.PosASMEnd || '-', data.PosASMAll || '-']"
      :titles="titles[2]"
      >
      </mon-card>
      <mon-card
      title="Позиций на сборке"
      :values="data.PosOnASM || '---'"
      :titles="titles[3]"
      >
      </mon-card>
      <mon-card
      title="Скорость сборки (поз./час)"
      :values="data.AVG_PosASM60min || '---'"
      :attention='speedAttention'
      :titles="titles[4]"
      >
      </mon-card>
      <mon-card
      title="Средняя скорость сборки (поз./час)"
      :values="data.AVG_PosASM || '---'"
      :titles="titles[5]"
      >
      </mon-card>
    </div>
  </div>
</template>

<script>
import MonCard from '~/components/MonCard.vue'
export default {
  props: {
    className: {
      type: String,
      default: 'cards'
    },
    id: {
      type: String,
      default: 'cards'
    },
    width: {
      type: String,
      default: '200px'
    },
    height: {
      type: String,
      default: '200px'
    },
    data: null
  },
  data () {
    return {
      title: ''
    }
  },
  components: {
    MonCard
  },
  computed: {
    speedAttention () {
      if (!this.data) return
      return (+this.data.AVG_PosASM60min >= +this.data.RSpeed) ? 'normal' : 'alert'
    },
    timeAttention () {
      if (!this.data) return
      return (this.data.ASMEndTimePlanT >= this.data.ASMEndTimeFactT) ? 'normal' : 'alert'
    },
    titles () {
      return [
        {
          title: 'Время окончания сборки, если текущая скорость сборки не изменится',
          values: (this.timeAttention === 'normal')
            ? 'При текущей скорости сборока будет закончена раньше планового времени'
            : 'При текущей скорости сборока будет закончена позже планового времени'
        },
        {
          title: 'Требуется закончить сборку к этому времени',
          values: 'Требуется закончить сборку к этому времени'
        },
        {
          title: 'Количество позиций, которые осталось собрать / Всего позиций, которые надо собрать',
          values: 'Количество позиций, которые осталось собрать / Всего позиций, которые надо собрать'
        },
        {
          title: 'Количество позиций, находящихся в данный момент на сборке',
          values: 'Количество позиций, находящихся в данный момент на сборке'
        },
        {
          title: 'Количество позиций, собранных за последний час',
          values: 'Количество позиций, собранных за последний час'
        },
        {
          title: 'Количество позиций, собираемых в среднем за час с начала смены',
          values: 'Количество позиций, собираемых в среднем за час с начала смены'
        }
      ]
    }
  }
}
</script>

<style>
.card-container {
  height: 100%;
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  justify-content: space-around;
  align-content: space-around;
}
</style>
