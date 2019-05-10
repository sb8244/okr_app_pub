export const listPath = () => '/list'
export const okrDetailPath = slug => `/${slug}`
export const okrGroupDetailPath = slug => `/g/${slug}`
export const ownerDetailPath = ({ owner_type, slug }) => {
  if (owner_type === 'user') {
    return okrDetailPath(slug)
  } else if (owner_type === 'group') {
    return okrGroupDetailPath(slug)
  }
}
