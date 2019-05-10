import React, { Component } from 'react'
import styled from 'styled-components'

const ColorText = styled.span`
  background-color: ${
    (props) => {
      const splitScore = props.score.split(':')
      const score = parseFloat(splitScore[splitScore.length - 1])

      if (score > 0.7) {
        return '#C3E55F'
      } else if (score >= 0.4) {
        return '#FFE66D'
      } else if (score > 0) {
        return 'rgba(255, 0, 0, 0.5)'
      } else {
        return 'inherit'
      }
    }
  };
`

const editableInputProps = {
  autoFocus: true,
  type: 'number',
  min: '0',
  max: '1',
  step: '0.1',
  onFocus: (e) => { e.currentTarget.select() }
}

class ScoringArea extends Component {
  state = {
    editing: {
      midScore: false,
      finalScore: false
    },
    editingValues: {}
  }

  changeEditingValue(field) {
    return (evt) => {
      const { editingValues } = this.state
      const newEditingValues = {
        ...editingValues,
        [field]: evt.target.value
      }
      this.setState({ editingValues: newEditingValues })
    }
  }

  deleteEditingValue(field) {
    const { editingValues } = this.state
    const newEditingValues = {
      ...editingValues,
      [field]: undefined
    }
    this.setState({ editingValues: newEditingValues })
  }

  handleKeyPress(field) {
    return (evt) => {
      if (evt.key === 'Enter') {
        this.update(field, evt)
      }
    }
  }

  toggleEditing(field) {
    if (this.props.editable) {
      const { editing } = this.state
      const newEditing = {
        ...editing,
        [field]: !editing[field]
      }

      this.setState({ editing: newEditing })
    }
  }

  update(field, evt) {
    const doneEditing = () => {
      this.toggleEditing(field)
      this.deleteEditingValue(field)
    }

    if (evt.target.value === "") {
      doneEditing()
    } else {
      this.props.saveFn(field, evt.target.value).then((d) => {
        doneEditing()
      })
    }
  }

  render() {
    const { className, editable, midScore, finalScore } = this.props
    const { editing, editingValues } = this.state

    const midScoreValue = editingValues.midScore === undefined ? midScore : editingValues.midScore
    const finalScoreValue = editingValues.finalScore === undefined ? finalScore : editingValues.finalScore

    return (
      <div className={className}>
        {
          editing.midScore ?
            <input
              {...editableInputProps}
              value={midScoreValue}
              onBlur={(evt) => this.update('midScore', evt)}
              onChange={this.changeEditingValue('midScore')}
              onKeyPress={this.handleKeyPress('midScore')}
            /> :
            <ColorText score={midScore} onClick={() => this.toggleEditing('midScore')}>
              {midScore}
            </ColorText>
        }

        {
          editing.finalScore ?
            <input
              {...editableInputProps}
              value={finalScoreValue}
              onBlur={(evt) => this.update('finalScore', evt)}
              onChange={this.changeEditingValue('finalScore')}
              onKeyPress={this.handleKeyPress('finalScore')}
            /> :
            <ColorText score={finalScore} onClick={() => this.toggleEditing('finalScore')}>
              {finalScore}
            </ColorText>
        }
      </div>
    )
  }
}

export default styled(ScoringArea)`
  text-align: right;

  span {
    display: inline-block;
    margin-right: 10px;
    padding: 5px;
    width: 80px;

    cursor: ${p => p.editable ? 'pointer' : 'inherit'}
    text-align: center;
  }

  input {
    height: 30px;
    margin-right: 10px;
    text-align: right;
    width: 80px;
  }
`
