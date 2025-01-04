import React, { useRef, useState } from 'react';
import './Quiz.css';
import { data } from '../data.js';

const Quiz = () => {
    const [showScoreScreen, setShowScoreScreen] = useState(false);
    const [index, setIndex] = useState(0);
    const [question, setQuestion] = useState(data[index]);
    const [score, setScore] = useState(0);
    const [lock, setLock] = useState(false);

    const Option1 = useRef(null);
    const Option2 = useRef(null);
    const Option3 = useRef(null);
    const Option4 = useRef(null);

    const optionArray = [Option1, Option2, Option3, Option4];

    const nextHandler = () => {
        if (!showScoreScreen) {
            setLock(false);
            // Set next question if there's a next question available
            if (index + 1 < data.length) {
                setIndex(prevIndex => prevIndex + 1);
                setQuestion(data[index + 1]);
            }

            // Reset option classes for the next question
            optionArray.forEach((option) => {
                option.current.classList.remove("correct");
                option.current.classList.remove("incorrect");
            });
        } else {
            // If it's the last question, show the score screen
            setShowScoreScreen(true);
        }
    };

    const startQuiz = () => {
        setShowScoreScreen(false);
        setIndex(0);
        setQuestion(data[0]);
        setScore(0);
    };

    const checkAns = (e, ans) => {
        if (!lock) {
            if (question.ans === ans) {
                e.target.classList.add('correct');
                setLock(true);
                setScore((prev) => prev + 1);
            } else {
                e.target.classList.add('incorrect');
                optionArray[question.ans - 1].current.classList.add("correct");
                setLock(true);
            }
        }
    };

    return (
        <div className='container'>
            <h1>Quiz app</h1>
            <hr />
            {
                showScoreScreen ? (
                    <>
                        <h2>{`Your score is ${score} out of ${data.length}`}</h2>
                        <button onClick={startQuiz}>Play Again</button>
                    </>
                ) : (
                    <>
                        <h2>{`${index + 1}. ${question.question}`}</h2>
                        <ul>
                            <li ref={Option1} onClick={(e) => checkAns(e, 1)}>{question.option1}</li>
                            <li ref={Option2} onClick={(e) => checkAns(e, 2)}>{question.option2}</li>
                            <li ref={Option3} onClick={(e) => checkAns(e, 3)}>{question.option3}</li>
                            <li ref={Option4} onClick={(e) => checkAns(e, 4)}>{question.option4}</li>
                        </ul>
                        <button onClick={nextHandler}>Next</button>
                        <div className='index'>{`Question ${index + 1} of ${data.length}`}</div>
                    </>
                )
            }
        </div>
    );
}

export default Quiz;
