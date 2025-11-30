import i18n from 'i18next'
import { initReactI18next } from 'react-i18next'

// Import translations
import commonRu from '../../../public/locales/ru/common.json'
import commonKk from '../../../public/locales/kk/common.json'
import commonEn from '../../../public/locales/en/common.json'

import authRu from '../../../public/locales/ru/auth.json'
import authKk from '../../../public/locales/kk/auth.json'
import authEn from '../../../public/locales/en/auth.json'

const resources = {
  ru: {
    common: commonRu,
    auth: authRu,
  },
  kk: {
    common: commonKk,
    auth: authKk,
  },
  en: {
    common: commonEn,
    auth: authEn,
  },
}

i18n
  .use(initReactI18next)
  .init({
    resources,
    lng: localStorage.getItem('language') || 'ru', // Default language
    fallbackLng: 'ru',
    ns: ['common', 'auth'],
    defaultNS: 'common',
    interpolation: {
      escapeValue: false, // React already escapes
    },
  })

export default i18n
