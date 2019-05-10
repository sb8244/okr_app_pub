import React, { Component } from 'react'
import styled from 'styled-components'

import { KeyResult } from '@utils/api'

import KeyResultActions from './KeyResultActions'
import EditableKeyResult from './EditableKeyResult'
import ScoringArea from './ScoringArea'

function updateKeyResultScore(keyResult, okr) {
  return (field, value) => {
    const params = {}
    if (field == 'midScore') {
      params.mid_score = value
    } else if (field === 'finalScore') {
      params.final_score = value
    }

    return KeyResult.update(keyResult.id, params).then(() => okr.keyResultUpdated())
  }
}

class KeyResultContent extends Component {
  state = {
    editingContent: false
  }

  setEditingContent = (editingContent) => {
    this.setState({ editingContent })
  }

  render() {
    const { className, keyResult, okr } = this.props
    const { editingContent } = this.state

    if (editingContent) {
      return (
        <div className={className}>
          <EditableKeyResult keyResult={keyResult} okr={okr} onEditingChange={this.setEditingContent} />
        </div>
      )
    }

    return (
      <div className={className}>
        <EditableKeyResult keyResult={keyResult} okr={okr} onEditingChange={this.setEditingContent} />
        <KeyResultActions keyResult={keyResult} okr={okr} />
        <ScoringArea editable={true} midScore={keyResult.mid_score} finalScore={keyResult.final_score} saveFn={updateKeyResultScore(keyResult, okr)} />
      </div>
    )
  }
}

const StyledKeyResultContent = styled(KeyResultContent)`
  display: flex;
  align-items: center;

  span {
    max-width: 70%;
    text-decoration: ${p => !!p.keyResult.cancelled_at ? 'line-through' : 'none'};
  }
`

export default StyledKeyResultContent
