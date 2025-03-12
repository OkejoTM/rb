<template>
    <div class="form-group" v-if="isShowContact()">
        <div class="form-inline">
            <input type="text"
                   v-model="contact.value"
                   class="form-control">
            <select class="form-control"
                    v-model="contact.contact_type_id">
                <option v-for="contact_type in contact_types"
                        :value="contact_type.id"
                        :selected="contact.contact_type_id == contact_type.id">{{contact_type.title_ru}}
                </option>
            </select>

            <button type="button"
                    class="btn btn-default"
                    @click="removeContact">
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
        props: ['contact', 'contact_types', 'errors'],
        components: {
            ErrorLabel
        },
        methods: {
            removeContact() {
                if (typeof this.contact._destroy === 'undefined') {
                    Vue.set(this.contact, '_destroy', 1);
                } else {
                    Vue.delete(this.contact, '_destroy');
                }
            },

            isShowContact() {
                return typeof this.contact._destroy === 'undefined';
            }
        }
    }
</script>