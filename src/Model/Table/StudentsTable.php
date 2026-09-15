<?php

namespace App\Model\Table;

use Cake\ORM\Table;

class StudentsTable extends Table
{
    public function initialize(array $config): void
    {
        parent::initialize($config);

        $this->setTable('students');
        $this->setPrimaryKey('id');
    }
}