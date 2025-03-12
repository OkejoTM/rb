<template>
    <!-- Modal -->
    <div class="modal fade" id="contactPersonModal" tabindex="-1" role="dialog" aria-labelledby="contactPersonLabel">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button"
                            class="close"
                            data-dismiss="modal"
                            aria-label="Close"
                            style="margin: 3px; text-indent: unset;">
                        <span aria-hidden="true">&times;</span>
                    </button>
                    <h4 class="modal-title" id="contactPersonLabel">Редактирование контактного лица</h4>
                </div>
                <div class="modal-body">

                    <div class="row">
                        <div class="col-lg-6">
                            <div class="form-group" style="align-items: center; display: flex;">
                                <label class="col-lg-2 control-label">Фото</label>

                                <div>
                                    <img-loader :image="editableContactPerson.avatar_attributes"
                                                @load_image="editableContactPerson.avatar_attributes = $event"></img-loader>
                                </div>
                            </div>
                        </div>

                        <div class="col-lg-6">
                            <div class="form-group">
                                <label for="name_ru"
                                       class="control-label">ФИО на Русском</label>

                                <input type="text" id="name_ru" class="form-control" v-model="editableContactPerson.name_ru">
                                <error-label :errors="error_by_name('name_ru')"
                                             v-if="error_by_name('name_ru')"></error-label>
                            </div>

                            <div class="form-group">
                                <label for="name_en"
                                       class="control-label">ФИО на Английском</label>

                                <input type="text" id="name_en" class="form-control" v-model="editableContactPerson.name_en">
                                <error-label :errors="error_by_name('name_en')"
                                             v-if="error_by_name('name_en')"></error-label>
                            </div>
                        </div>
                    </div>


                    <div class="form-group">
                        <label for="role_ru"
                               class="control-label">Должность на Русском</label>

                        <input type="text" id="role_ru" class="form-control" v-model="editableContactPerson.role_ru">
                    </div>

                    <div class="form-group">
                        <label for="role_en"
                               class="control-label">Должность на Английском</label>

                        <input type="text" id="role_en" class="form-control" v-model="editableContactPerson.role_en">
                    </div>

                    <!-- Контактные данные контактного лица -->
                    <h4>
                        Контакты
                        <button type="button"
                                class="btn btn-success"
                                @click="addContact(editableContactPerson, 'ContactPerson')">Добавить
                            <i class="glyphicon glyphicon-plus"></i></button>
                    </h4>

                    <div class="col-lg-offset-3"
                         v-for="(contact, index) in editableContactPerson.contacts_attributes"
                         :key="contact.id">
                        <contact :contact="contact"
                                 :contact_types="contact_types"></contact>
                                 <!--:errors="contact.errors"></contact>-->
                                 <!--:errors="error_by_name('contacts[' + index + ']')"></contact>-->
                    </div>


                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Отмена</button>
                    <button type="button"
                            class="btn btn-primary"
                            data-dismiss="modal"
                            @click="save()">Сохранить</button>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
    import ImgLoader from './img_loader.vue'
    import Contact from './contact.vue'
    import ErrorLabel from './error_label.vue'

    export default {
        data() {
            return {
                editableContactPerson: Object.assign({}, this.contact_person)
            }
        },
        props: ['contact_person', 'contact_types', 'default_contact', 'contact_person_errors'],
        components: {
            ImgLoader,
            Contact,
            ErrorLabel,
        },
        watch: {
            contact_person: function (newObj, oldObj) {
                this.editableContactPerson = Object.assign({}, newObj);
            }
        },
        methods: {
            addContact(obj, contactable_type) {
                let new_default_contact = $.extend(this.default_contact, {
                    contactable_id: obj.id,
                    contactable_type: contactable_type
                });
                obj.contacts_attributes.push(Object.assign(new_default_contact));
            },

            save() {
                // this.$emit('save_contact_person', this.editableContactPerson);
                Object.assign(this.contact_person, this.editableContactPerson);
            },

            error_by_name(error_name) {
                if (this.contact_person_errors_exists() &&
                    error_name in this.contact_person_errors) {
                    return this.contact_person_errors[error_name];
                } else {
                    return null;
                }
            },

            contact_person_errors_exists() {
                return this.contact_person_errors != null && this.contact_person_errors != undefined
            }
        }
    }
</script>