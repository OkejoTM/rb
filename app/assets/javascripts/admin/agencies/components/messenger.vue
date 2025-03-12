<template>
    <div class="form-group" v-if="isShowMessenger()">
        <div class="form-inline">
            <input type="text"
                   v-model="messenger.phone"
                   class="form-control">
            <select class="form-control"
                    v-model="messenger.messenger_type_id">
                <option v-for="messenger_type in messenger_types"
                        :value="messenger_type.id"
                        :selected="messenger.messenger_type_id == messenger_type.id">{{messenger_type.title}}
                </option>
            </select>

            <button type="button"
                    class="btn btn-default"
                    @click="removeMessenger">
                <i class="glyphicon glyphicon-remove-sign"></i>
            </button>

            <error-label :errors="errors"></error-label>
        </div>
    </div>
</template>

<script>
    import ErrorLabel from './error_label.vue'

    export default {
        data() {
            return {}
        },
        props: ['messenger', 'messenger_types', 'errors'],
        components: {
            ErrorLabel
        },
        methods: {
            removeMessenger() {
                if (typeof this.messenger._destroy === 'undefined') {
                    Vue.set(this.messenger, '_destroy', 1);
                } else {
                    Vue.delete(this.messenger, '_destroy');
                }
            },

            isShowMessenger() {
                return typeof this.messenger._destroy === 'undefined';
            }
        }
    }
</script>