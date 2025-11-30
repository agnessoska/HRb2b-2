/**
 * Получить локализованное поле из объекта БД
 *
 * @example
 * const category = { name_ru: 'IT', name_kk: 'АТ', name_en: 'IT' }
 * const localizedName = getLocalizedField(category, 'name', 'ru') // 'IT'
 */
export function getLocalizedField<T extends Record<string, any>>(
  object: T,
  fieldName: string,
  language: string
): string {
  const localizedKey = `${fieldName}_${language}` as keyof T
  const fallbackKey = `${fieldName}_ru` as keyof T

  return (object[localizedKey] as string) || (object[fallbackKey] as string) || ''
}
