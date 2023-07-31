import React, { useEffect, useRef } from 'react'
import { useParams } from 'react-router-dom'
import { fetchFn } from '../etc/NetworkUtils';


function MemberDelete() {

    const LOGINER = localStorage.getItem("LOGINER");
    const username = useParams().username;
    const passwordRef = useRef();

    // ***findByUsername
    useEffect(()=>{
        fetchFn("GET", `http://localhost:8000/member-service/members/username/${username}`, null)
        .then(data=>{
            if (LOGINER === data.username){
                passwordRef.current.focus()  
            } else {
                window.location.href=`/`;
            }  
        })
    },[username, LOGINER]);



  return (
    <div>
        <h2>회원 삭제</h2>

        username : <input value={username} readOnly/><br/>
        password : <input ref={passwordRef} placeholder='비밀번호를 입력하세요.'/><br/>

        <button onClick={()=>{
            const password = passwordRef.current.value;
            const dto = {
                username, password
            }

            // ***delete
            fetchFn("DELETE", "http://localhost:8000/member-service/members/delete", dto)
            .then(data =>{
                if(data === undefined){
                    passwordRef.current.value="";
                    return;
                }
                localStorage.setItem("BTOKEN", null);
                localStorage.setItem("LOGINER", null);
                localStorage.setItem("ROLE", null);
                window.location.href="/";
            })
        }}>삭제</button>

    </div>
  )
}

export default MemberDelete