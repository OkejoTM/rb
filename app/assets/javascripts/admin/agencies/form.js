import { noty_success, noty_error } from '../init_noty.js'

import CKEditor from '@ckeditor/ckeditor5-vue';
import axios from 'axios'

import Messenger from './components/messenger.vue'
import Contact from './components/contact.vue'
import ErrorLabel from './components/error_label.vue'
// import LoadingAlert from './components/loading_alert.vue'
// import loading_alert_states from './components/loading_alert_states'
import ImgLoader from './components/img_loader.vue'
import ContactPersonModal from './components/contact_person_modal'

$(function () {
    if ($('#agency').length > 0) {

        let json_data = JSON.parse($('#agency_json').html());

        new Vue({
            el: '#agency',
            data: {
                agency: json_data['agency'],
                htmlParams: json_data['html_params'],
                // alertState: loading_alert_states.NO_INIT,
                editor: ClassicEditor,
                errors: [],
                isSaveBtnDisabled: false,
                editableContactPerson: this.defaultContactPerson,
                editableContactPersonErrors: {}
            },
            components: {
                Messenger,
                Contact,
                ErrorLabel,
                // LoadingAlert,
                ImgLoader,
                ContactPersonModal,
                ckeditor: CKEditor.component
            },
            methods: {
                saveAgency(e) {
                    this.isSaveBtnDisabled = true;
                    // window.scrollTo(0, 0);

                    // this.alertState = loading_alert_states.LOADING;

                    let axios_req = null;
                    if (this.isNew()) {
                        axios_req = axios.post('/agencies.json', {
                            agency: this.agency
                        })

                    } else {
                        axios_req = axios.put(`/agencies/${this.agency.id}.json`, {
                            agency: this.agency
                        })
                    }

                    axios_req.then((response) => {
                        this.agency = response.data['agency'];
                        this.errors = [];

                        noty_success(response.data['html_params']['notice']);
                        // this.alertState = loading_alert_states.SUCCESS;

                        let edit_path = response.data['html_params']['edit_path'];
                        if (edit_path != null && edit_path != undefined) {
                            window.history.replaceState({}, "", edit_path);
                        }
                    })
                    .catch((errors) => {
                        this.errors = errors.response['data']['errors'];

                        this.fillErrorsByName(this.agency.contacts_attributes, 'contacts', this.errors);
                        this.fillErrorsByName(this.agency.messengers_attributes, 'messengers', this.errors);
                        this.fillErrorsByName(this.agency.contact_people_attributes, 'contact_people', this.errors);

                        noty_error(errors.response['data']['notice']);
                        // this.alertState = loading_alert_states.ERROR;
                    })
                    .finally(() => {
                        this.isSaveBtnDisabled = false;
                    });
                },

                addMessenger() {
                    this.agency.messengers_attributes.push(this.defaultMessenger());
                },

                addContact(obj, contactable_type) {
                    obj.contacts_attributes.push(this.defaultContact(contactable_type));
                },

                isNew() {
                    return this.agency.id === 'undefined' || this.agency.id === null
                },

                // --- CONTACT PERSON ---
                addContactPerson() {
                    let default_contact_person = $.extend(this.defaultContactPerson(), { agency_id: this.agency.id });
                    this.agency.contact_people_attributes.push(default_contact_person);
                },

                removeContactPerson(contact_person) {
                    let idx = this.agency.contact_people_attributes.indexOf(contact_person);
                    if (idx != -1) {
                        // Второй параметр - число элементов, которые необходимо удалить
                        // this.agency.contact_people_attributes.splice(idx, 1);
                        let removable_contact_person = this.agency.contact_people_attributes[idx];

                        if (typeof removable_contact_person['_destroy'] === "undefined" || !removable_contact_person['_destroy']) {
                            Vue.set(removable_contact_person, '_destroy', 1);
                        } else {
                            Vue.delete(removable_contact_person, '_destroy');
                        }
                    }
                },

                editContactPerson(contact_person) {
                    this.editableContactPerson = contact_person;
                    this.editableContactPersonErrors = contact_person['errors'];

                    $('#contactPersonModal').modal('show');
                },
                // --- / CONTACT PERSON ---

                defaultMessenger() {
                    return {
                        messenger_type_id: this.htmlParams.messenger_types[0].id,
                        phone: '',
                        agency_id: this.agency.id
                    }
                },

                defaultContact(contactable_type) {
                    return {
                        value: '',
                        contactable_id: this.agency.id,
                        contactable_type: contactable_type,
                        contact_type_id: this.htmlParams.contact_types[0].id
                    }
                },

                defaultContactPerson() {
                    return {
                        role_ru: '',
                        role_en: '',
                        name_ru: '',
                        name_en: '',
                        contacts_attributes: [],
                        avatar_attributes: new Object({
                            pic: {
                                url: ''
                            },
                            _destroy: 1
                        })

                        // contacts_attributes
                    }
                },

                // Выбирает из errors ошибки по ключу name
                // и записывает их в соответствующий nested_attributes[i].errors
                fillErrorsByName(nested_attributes, name, errors) {
                    for (let i = 0; i < nested_attributes.length; i++) { // для каждого атрибута ищем соответствующие ему ошибки
                        nested_attributes[i].errors = {};
                        for (let key in errors) { // для каждой ошибки
                            let error_key = `${name}[${i}].`; // вычисляем ключ для ошибки текущего атрибута
                            if (key.indexOf(error_key) === 0) { // если есть соответствующая ошибка
                                // записываем найденную ошибку в список ошибок текущего атрибута
                                let na_error_key = key.slice(key.indexOf(error_key) + error_key.length, key.length);
                                nested_attributes[i].errors[na_error_key] = errors[key];
                            }
                        }
                    }
                }
            }
        });

    }
});