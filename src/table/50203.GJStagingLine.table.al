table 50203 "GJ Staging Line"
{
    Caption = 'GJ Staging Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Upload Id"; Guid) { }
        field(2; "Row No."; Integer) { }
        field(3; "Col1"; Text[250]) { }
        field(4; "Col2"; Text[250]) { }
        field(5; "Col3"; Text[250]) { }
        field(6; "Col4"; Text[250]) { }
        field(7; "Col5"; Text[250]) { }
        field(8; "Col6"; Text[250]) { }
        field(9; "Col7"; Text[250]) { }
        field(10; "Col8"; Text[250]) { }
        field(11; "Col9"; Text[250]) { }
        field(12; "Col10"; Text[250]) { }
        field(13; "Col11"; Text[250]) { }
        field(14; "Col12"; Text[250]) { }
        field(15; "Col13"; Text[250]) { }
        field(16; "Col14"; Text[250]) { }
        field(17; "Col15"; Text[250]) { }
        field(18; "Col16"; Text[250]) { }
        field(19; "Col17"; Text[250]) { }
        field(20; "Col18"; Text[250]) { }
        field(21; "Col19"; Text[250]) { }
        field(22; "Col20"; Text[250]) { }
        field(23; "Col21"; Text[250]) { }
        field(24; "Col22"; Text[250]) { }
        field(25; "Col23"; Text[250]) { }
        field(26; "Col24"; Text[250]) { }
        field(27; "Col25"; Text[250]) { }
        field(28; "Col26"; Text[250]) { }
        field(29; "Col27"; Text[250]) { }
        field(30; "Col28"; Text[250]) { }
        field(31; "Col29"; Text[250]) { }
        field(32; "Col30"; Text[250]) { }
        field(33; "Col31"; Text[250]) { }
        field(34; "Col32"; Text[250]) { }
        field(35; "Col33"; Text[250]) { }
        field(36; "Col34"; Text[250]) { }
        field(37; "Col35"; Text[250]) { }
        field(38; "Col36"; Text[250]) { }
        field(39; "Col37"; Text[250]) { }
        field(40; "Col38"; Text[250]) { }
        field(41; "Col39"; Text[250]) { }
        field(42; "Col40"; Text[250]) { }
        field(43; "Col41"; Text[250]) { }
        field(44; "Col42"; Text[250]) { }
        field(45; "Col43"; Text[250]) { }
        field(46; "Col44"; Text[250]) { }
        field(47; "Col45"; Text[250]) { }
        field(48; "Col46"; Text[250]) { }
        field(49; "Col47"; Text[250]) { }
        field(50; "Col48"; Text[250]) { }
        field(51; "Col49"; Text[250]) { }
        field(52; "Col50"; Text[250]) { }
        // Add more fields if needed, and maintain the same pattern. Field references should be incremental and no gaps.Your field will start from 53 and name it Col51, Col52, and so on. An exmaple of the next few fields is shown below:
        // field(53; "Col51"; Text[250]) { }
        // field(54; "Col52"; Text[250]) { }
    }

    keys { key(PK; "Upload Id", "Row No.") { Clustered = true; } }
}