import PropTypes from 'prop-types'

export const CycleShape = {
  ends_at: PropTypes.string,
  id: PropTypes.number,
  starts_at: PropTypes.string,
  title: PropTypes.string,
}

export const OkrShape = {
  id: PropTypes.number,
  cycle: PropTypes.shape(CycleShape),
  objectives: PropTypes.array,
}

export const KeyResultShape = {
  cancelled_at: PropTypes.string,
  content: PropTypes.string,
  final_score: PropTypes.string,
  id: PropTypes.number,
  inserted_at: PropTypes.string,
  mid_score: PropTypes.string,
  updated_at: PropTypes.string,
}

export const ObjectiveShape = {
  id: PropTypes.number.isRequired,
  cancelled_at: PropTypes.string,
  content: PropTypes.string,
  id: PropTypes.number,
  inserted_at: PropTypes.string,
  key_results: PropTypes.arrayOf(PropTypes.shape(KeyResultShape)),
  updated_at: PropTypes.string,
  mid_score: PropTypes.string,
  final_score: PropTypes.string,
}
