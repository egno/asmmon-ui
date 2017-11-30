<template>
  <section class="container">
    <mon-main
    :server="code"
    width="100%"
    height="50%">
    </mon-main>
  </section>
</template>

<script>
import MonMain from '~/components/MonMain.vue'

export default {
  computed: {
    code () {
      return this.$route.params.code
    }
  },
  components: {
    MonMain
  }
}
</script>

<style>
.container {
  min-height: 100vh;
  display: flex;
  justify-content: center;
  /*align-items: center;*/
  text-align: center;
}

.title {
  font-family: "Quicksand", "Source Sans Pro", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif; /* 1 */
  display: block;
  font-weight: 300;
  font-size: 100px;
  color: #35495e;
  letter-spacing: 1px;
}

.subtitle {
  font-weight: 300;
  font-size: 42px;
  color: #526488;
  word-spacing: 5px;
  padding-bottom: 15px;
}

.links {
  padding-top: 15px;
}
</style>
