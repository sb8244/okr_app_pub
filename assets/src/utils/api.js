const FETCH_OPTS = {
  credentials: 'same-origin',
  headers: {
    'Content-Type': 'application/json; charset=utf-8',
    'X-CSRF-Token': Array.from(document.head.children).filter(
      el => el.name === 'csrf-token'
    )[0].content,
  },
}

const TRANSFORM_DATA = ({ data }) => data

export function getRequest(resource, query = undefined) {
  return new Promise((resolve, reject) => {
    let url = `/api/${resource}`

    if (query) {
      url += '?' + new URLSearchParams(query).toString()
    }

    fetch(url, FETCH_OPTS).then(response => {
      if (response.status >= 400) {
        return reject(response)
      }

      resolve(response.json())
    })
  })
}

function request(type, resource, params) {
  return new Promise((resolve, reject) => {
    const url = `/api/${resource}`
    const opts = {
      ...FETCH_OPTS,
      method: type,
      body: JSON.stringify(params),
    }

    fetch(url, opts).then(response => {
      if (response.status >= 400) {
        return reject(response)
      } else if (response.status === 204) {
        return resolve({})
      }

      resolve(response.json())
    })
  })
}

export const Group = {
  findBySlug(slug) {
    return getRequest('groups', { slug }).then(({ data }) => {
      if (data && data.length === 1) {
        return data[0]
      } else {
        throw new Error(`There were ${data.length} groups found for this URL`)
      }
    })
  },

  search(search) {
    return getRequest('groups', { search }).then(TRANSFORM_DATA)
  },
}

export const User = {
  findBySlug(slug) {
    return getRequest('users', { slug, active: true }).then(({ data }) => {
      if (data && data.length === 1) {
        return data[0]
      } else {
        throw new Error(`There were ${data.length} users found for this URL`)
      }
    })
  },

  me() {
    return getRequest('user').then(TRANSFORM_DATA)
  },

  search(search) {
    return getRequest('users', { search, active: true }).then(TRANSFORM_DATA)
  },
}

export const Cycle = {
  allFuture() {
    return getRequest('cycles', { present_or_future: true }).then(
      TRANSFORM_DATA
    )
  },
}

export const KeyResult = {
  create(params) {
    return request('POST', `key_results`, params).then(TRANSFORM_DATA)
  },

  update(id, params) {
    return request('PUT', `key_results/${id}`, params).then(TRANSFORM_DATA)
  },
}

export const Objective = {
  create(params) {
    return request('POST', `objectives`, params).then(TRANSFORM_DATA)
  },

  update(id, params) {
    return request('PUT', `objectives/${id}`, params).then(TRANSFORM_DATA)
  },

  createObjectiveLink({ sourceId, targetId }) {
    const params = {
      source_objective_id: sourceId,
      linked_to_objective_id: targetId,
    }
    return request('POST', 'objective_links', params).then(TRANSFORM_DATA)
  },

  deleteObjectiveLink({ contributesToObjectiveId, contributedByObjectiveId }) {
    const lookupParams = {
      source_objective_id: contributedByObjectiveId,
      linked_to_objective_id: contributesToObjectiveId,
    }
    return getRequest('objective_links', lookupParams).then(({ data }) => {
      if (data.length === 1) {
        const linkingId = data[0].id
        return request('DELETE', `objective_links/${linkingId}`).then(
          TRANSFORM_DATA
        )
      } else {
        throw new Error('Error occurred looking up the objective link')
      }
    })
  },
}

export const Okr = {
  create(params) {
    return request('POST', `okrs`, params).then(TRANSFORM_DATA)
  },

  forGroup({ id }) {
    return getRequest(`groups/${id}/okrs`).then(TRANSFORM_DATA)
  },

  forUser({ id }) {
    return getRequest(`users/${id}/okrs`).then(TRANSFORM_DATA)
  },
}

export const Analytics = {
  getActiveUserReport() {
    return getRequest('analytics/active_user').then(TRANSFORM_DATA)
  },

  getOkrViewReport(ownerId) {
    return getRequest(`analytics/okr_view/${ownerId}`).then(TRANSFORM_DATA)
  },
}

export const ObjectiveAssessment = {
  create(params) {
    return request('POST', 'objective_assessments', params).then(TRANSFORM_DATA)
  },

  update(id, params) {
    return request('PUT', `objective_assessments/${id}`, params).then(
      TRANSFORM_DATA
    )
  },
}

export const OkrReflection = {
  create(params) {
    return request('POST', 'okr_reflections', params).then(TRANSFORM_DATA)
  },

  update(id, params) {
    return request('PUT', `okr_reflections/${id}`, params).then(TRANSFORM_DATA)
  },
}
