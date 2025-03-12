<template>
    <ul>
        <li v-for="error in errors"
            style="color: red;">{{error}}
        </li>
    </ul>
</template>

<script>
    export default {
        data() {
            return {}
        },
        props: ['errors']
    }
</script>