<template>
    <div class="row" v-if="isShowAlert()">
        <div :class="getClass()"
             role="alert">
            <button type="button"
                    class="close"
                    data-dismiss="alert"
                    aria-label="Close"
                    style="margin: 3px; text-indent: unset;">
                <span aria-hidden="true">&times;</span>
            </button>
            <strong>{{getMessage()}}</strong>
        </div>
    </div>
</template>

<script>
    import loading_alert_states from './loading_alert_states'

    export default {
        data() {
            return {}
        },
        props: ['alert_state'],
        methods: {
            getMessage() {
                switch (this.alert_state) {
                    case loading_alert_states.LOADING:
                        return 'Updating...';
                    case loading_alert_states.SUCCESS:
                        return 'Success!';
                    case loading_alert_states.ERROR:
                        return 'Error!';
                    default:
                        return '';
                }
            },

            getClass() {
                let style = 'alert ';

                switch (this.alert_state) {
                    case loading_alert_states.LOADING:
                        style += 'alert-info ';
                        break;
                    case loading_alert_states.SUCCESS:
                        style += 'alert-success ';
                        break;
                    case loading_alert_states.ERROR:
                        style += 'alert-danger ';
                        break;
                    default:
                        return '';
                }

                return style + 'alert-dismissible';
            },

            isShowAlert() {
                return this.alert_state != loading_alert_states.NO_INIT;
            }
        }
    }
</script>