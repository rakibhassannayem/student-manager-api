<?php

namespace App\Controller;

class StudentsController extends AppController
{
    public function index()
    {
        $students = $this->fetchTable('Students')
            ->find()
            ->all();

        return $this->response
            ->withType('application/json')
            ->withStringBody(json_encode($students));
    }
}
