function collectAndSaveNestedData(structure)
    % 再帰的にデータを収集する関数
    global collectedData;
    collectedData = struct();
    collectData(structure, '');
    
    % CSVファイルに保存
    saveDataToCSV_v2();
end

function collectData(structure, parentField)
    % 再帰的にデータを収集
    global collectedData;
    fields = fieldnames(structure);
    for i = 1:length(fields)
        currentField = fields{i};
        fullFieldName = strcat(parentField, '.', currentField);
        if isstruct(structure.(currentField))
            collectData(structure.(currentField), fullFieldName);
        else
            % フルフィールド名でデータを格納
            if isempty(parentField)
                fullFieldName = currentField; % 親フィールドがない場合
            end
            collectedData.(fullFieldName) = structure.(currentField);
        end
    end
end

function saveDataToCSV_v2()
    % 新しい形式でCSVに保存
    global collectedData;
    filename = 'nestedData_v2.csv';
    fid = fopen(filename, 'w');
    
    % ヘッダーの書き込み
    fieldNames = fieldnames(collectedData);
    fprintf(fid, 'TimeStep,%s\n', join(fieldNames, ','));
    
    % データの最大長を取得
    maxLength = max(cellfun(@(f) numel(collectedData.(f)), fieldNames));
    
    % 時間ステップの開始値と刻み幅を設定
    timeStepStart = 0;
    timeStepIncrement = 0.001;
    
    % 時間ステップごとにデータを書き込み
    for i = 1:maxLength
        currentTime = timeStepStart + (i-1) * timeStepIncrement;
        rowData = cellfun(@(f) getDataAtIndex(collectedData.(f), i), fieldNames, 'UniformOutput', false);
        fprintf(fid, '%f,%s\n', currentTime, join(rowData, ','));
    end
    
    fclose(fid);
end

function dataStr = getDataAtIndex(data, index)
    % 指定されたインデックスのデータを文字列で返す
    if index <= numel(data)
        dataStr = num2str(data(index));
    else
        dataStr = '';
    end
end
