<template>
    <div>
        <div v-if="isShowImage()">
            <div class="item mfp-gallery">
                <a class="item mfp-gallery" :href="image.pic.url">
                    <img :src="imagePreview" class="img-thumbnail" style="max-width: 170px; max-height: 130px;"/>
                </a>

                <button @click="removeImage"
                        class="btn btn-default"><i class="glyphicon glyphicon-remove-sign"></i></button>
            </div>
        </div>

        <div v-else>
            <input type="file"
                   @change="onFileChange"
                   id="files"
                   ref="inputFile"
                   style="display: none;">
            <button @click="$refs.inputFile.click()"
                    class="btn btn-success">Загрузить
            </button>
            <p class="help-block">выберите файл для загрузки</p>
        </div>

        <br>
    </div>
</template>

<script>
    export default {
        data() {
            return {
                imagePreview: this.imagePreviewSrc()
            }
        },
        props: {
            image: {
                type: Object
            }
        },
        watch: {
            image: function (newImage, oldImage) {
                this.imagePreview = this.imagePreviewSrc();
            }
        },
        methods: {
            onFileChange(e) {
                let files = e.target.files || e.dataTransfer.files;
                if (!files.length)
                    return;
                this.createImage(files[0]);
            },

            createImage(file) {
                let reader = new FileReader();

                reader.onload = (e) => {
                    this.$emit('load_image', {pic: e.target.result});
                };

                reader.readAsDataURL(file);
            },

            removeImage() {
                if (typeof this.image['_destroy'] === "undefined" || !this.image['_destroy']) {
                    Vue.set(this.image, '_destroy', 1);
                } else {
                    Vue.delete(this.image, '_destroy');
                }
            },

            imagePreviewSrc() {
                if (typeof this.image === "undefined" || this.image === null) {
                    return '';
                }

                if (this.image && this.image.pic && this.image.pic.mini && this.image.pic.mini.url) {
                    return this.image.pic.mini.url;
                } else {
                    return this.image.pic;
                }
            },

            isShowImage() {
                return typeof this.image !== "undefined" &&
                    this.image !== null &&
                    typeof this.image['_destroy'] === "undefined";
            }
        }
    }
</script>