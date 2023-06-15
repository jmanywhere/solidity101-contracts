// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

//-------------------------------------------------------------------------
//    ERRORS
//-------------------------------------------------------------------------

error CursoSolidityGT__YaInscrito();
error CursoSolidityGT__InscripcionCerrada();
error CursoSolidityGT__SoloMaestro();
error CursoSolidityGT__ETHTransferFailed();
error CursoSolidityGT__Reentrancy();

/**
 * @title Contrato Base para repartir ETH a los alumnos de la clase
 * @author SemiInvader
 * @notice Este contrato ya fue desplegado en Sepolia ETH 0x05873e54d8c1800a57d93b3ffd24f79e78db74f0
 * @dev NO USAR ESTE CODIGO EN PRODUCCION
 *      - Faltan pruebas
 *      - Falta más getters
 *      - Falta setters
 *      - Falta contemplar más información
 */

contract CursoSolidityGT {
    //-------------------------------------------------------------------------
    //    State Variables
    //-------------------------------------------------------------------------

    mapping(address => bool) public inscrito;
    address[] public alumnos;
    address public owner;

    uint public horaDeInscripcion;
    uint private reentrant = 1;

    //-------------------------------------------------------------------------
    //    Events
    //-------------------------------------------------------------------------

    event InscripcionCompleta(address indexed _user);
    event AbrirInscripciones(uint horaDeCierre);

    //-------------------------------------------------------------------------
    //    Modifiers
    //-------------------------------------------------------------------------

    modifier onlyOwner() {
        if (msg.sender != owner) revert CursoSolidityGT__SoloMaestro();
        _;
    }

    modifier nonReentrant() {
        if (reentrant != 1) revert CursoSolidityGT__Reentrancy();
        reentrant = 2;
        _;
        reentrant = 1;
    }

    constructor() {
        owner = msg.sender;
    }

    //-------------------------------------------------------------------------
    //    External Functions
    //-------------------------------------------------------------------------

    /**
     * @notice Can receive underlying ETH
     */
    receive() external payable {}

    /**
     * @notice Función para inscribir a participantes
     * @dev cada participante tiene que llamar a esta función para ser aceptado
     */
    function inscribirme() external {
        if (block.timestamp > horaDeInscripcion)
            revert CursoSolidityGT__InscripcionCerrada();
        if (inscrito[msg.sender]) revert CursoSolidityGT__YaInscrito();

        inscrito[msg.sender] = true;
        alumnos.push(msg.sender);

        emit InscripcionCompleta(msg.sender);
    }

    /**
     * @notice Esta función distribuye el ETH del contrato a los alumnos
     * @dev es una forma básica de enviar fondos a varias personas. Pero no es la más eficiente
     *      Lo más eficiente sería que cada usuario pueda reclamar la cantidad de ETH y el contrato solo lleva el registro
     *      de quienes ya han reclamado y quienes no.
     */
    function distribuirETH() external onlyOwner nonReentrant {
        uint ethParaAlumnos = address(this).balance;
        uint total = cantidadDeAlumnos();

        ethParaAlumnos = ethParaAlumnos / total;

        bool succ;
        for (uint i = 0; i < total; i++) {
            (succ, ) = payable(alumnos[i]).call{value: ethParaAlumnos}("");
            if (!succ) revert CursoSolidityGT__ETHTransferFailed();
        }
    }

    /**
     * @notice funcion para abrir las inscripciones
     * @dev lo ideal sería que luego de que se abren las inscripciones, luego ya no se pueda volver a abrir o
     *      debería de requerir un contrato diferente
     */
    function abrirInscripciones() external onlyOwner {
        horaDeInscripcion = block.timestamp + 15 minutes;
        emit AbrirInscripciones(horaDeInscripcion);
    }

    //-------------------------------------------------------------------------
    //    External and Public View / Pure Functions
    //-------------------------------------------------------------------------
    /**
     * @notice devuelve la cantidad de alumnos inscritos
     */
    function cantidadDeAlumnos() public view returns (uint) {
        return alumnos.length;
    }
}
